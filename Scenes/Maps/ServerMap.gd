extends Node2D


var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn") #change to mino
var melee_attack = preload("res://Scenes/Player/Melee_Attack.tscn")
var item_drop = preload("res://Scenes/Props/ItemGround.tscn")
onready var server = get_node("/root/Server")

var si = ServerInterface
var enemy_id_counter = 1 
var enemy_maximum = 3
var enemy_types = ["Slime" ,"Mino"] #list of enemies that spawn
var enemy_spawn_points = [Vector2 (250, 225), Vector2 (500, 150), Vector2 (570, 470)]
var open_locations = [0,1,2]
var occupied_locations = {}
var enemy_list = {}

var ore_list = ServerData.mining_data
var ore_types = [si.GOLD_ORE]

func _ready(): 
	var timer = Timer.new() 
	timer.wait_time = 1
	timer.autostart = true
	timer.connect("timeout", self, "respawn_enemies")
	self.add_child(timer)
	
func respawn_enemies():
	if enemy_list.size() >= enemy_maximum:
		pass #maximum enemies already on the map
	else:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()] #select random enemy
		var rng_location_index = randi() % open_locations.size()
		var location = enemy_spawn_points[open_locations[rng_location_index]]  #select random location to spawn at
		occupied_locations[enemy_id_counter] = open_locations[rng_location_index]
		open_locations.remove(rng_location_index)
		enemy_list[enemy_id_counter] = {
		 si.ENEMY_TYPE: type, #EnemyType
		 si.ENEMY_LOCATION : location, #EnemyLocation
		 si.ENEMY_CURRENT_HEALTH : EnemyData.enemies[type]["MaxHealth"], #EnemyCurrentHealth
		 si.ENEMY_MAX_HEALTH: EnemyData.enemies[type]["MaxHealth"], #EnemyMaxHealth
		 si.ENEMY_STATE: Enemy.State.IDLE,
		 si.ENEMY_TIME_OUT: 1}
		spawn_enemy(enemy_id_counter, location, type, enemy_list[enemy_id_counter])
		enemy_id_counter += 1
	for enemy in enemy_list.keys():
		if enemy_list[enemy][si.ENEMY_STATE] == Enemy.State.DESPAWN:
			if enemy_list[enemy][si.ENEMY_TIME_OUT] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy][si.ENEMY_TIME_OUT] -= 1

	
func release_occupied_location(enemy_id):
	open_locations.append(occupied_locations[enemy_id])
	occupied_locations.erase(enemy_id)

# warning-ignore:unused_argument
func spawn_enemy(enemy_id, location, type, status_dict):
	var enemy_spawn
	if type == "Slime":
		enemy_spawn = slime
	elif type == "Mino":
		enemy_spawn = mino	
	var enemy_spawn_instance = enemy_spawn.instance()
	enemy_spawn_instance.name = str(enemy_id)
	enemy_spawn_instance.position = location
	enemy_spawn_instance.set_status_dict(status_dict)
	get_node("YSort/Enemies/").add_child(enemy_spawn_instance, true)
	
func use_melee_attack(player_id, blend_position, player_position):
	var melee_attack_instance = melee_attack.instance()
	melee_attack_instance.player_id = player_id
	melee_attack_instance.position = player_position
	melee_attack_instance.change_rotation(blend_position)
	get_node("PlayerAttacks").add_child(melee_attack_instance)
	server.broadcast_packet(Players.get_players([player_id]),
			si.create_player_attack_swing_packet(player_id, 0))
	
func spawn_item_drop(tagged_by_player : int, drop_position : Vector2, item_id : int):
	var new_item_drop = item_drop.instance()
	new_item_drop.position = drop_position
	new_item_drop.item_id = item_id
	new_item_drop.tagged_by_player = tagged_by_player
	get_node("YSort/Items").add_child(new_item_drop)
	
func get_items_on_ground() -> Array:
#	var item_nodes : Array = get_node("YSort/Items").get_children()
	var item_node_names : Array
	for item in get_node("YSort/Items").get_children():
		item_node_names.append([item.item_id, item.name, item.position, item.tagged_by_player])	
	return item_node_names

func get_enemy_state_packets() -> Array:
	var enemy_state_packets = []
	for enemy in get_node("YSort/Enemies").get_children():
		if (enemy as Enemy).state != Enemy.State.DESPAWN:
			enemy_state_packets.append(enemy.get_state_packet())
	return enemy_state_packets
