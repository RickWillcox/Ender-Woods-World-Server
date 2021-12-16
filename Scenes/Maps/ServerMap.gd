extends Node2D

#Enemies
var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn")
var batsquito = preload("res://Scenes/Enemies/Batsquito.tscn")
var deer = preload("res://Scenes/Enemies/Deer.tscn")

var melee_attack = preload("res://Scenes/Player/Melee_Attack.tscn")
var item_drop = preload("res://Scenes/Props/ItemGround.tscn")

var si = ServerInterface
var enemy_types = ["Slime" ,"Mino", "Batsquito", "Deer"] #list of enemies that spawn

var ore_list = ServerData.mining_data
var ore_types = [si.GOLD_ORE]

onready var server = get_node("/root/Server")

func _ready(): 
	EnemySpawnData.connect("spawn_enemy", self, "spawn_enemy")

func spawn_enemy(enemy_id, location, type, status_dict):
	var enemy_spawn = batsquito
	if type == "Slime":
		enemy_spawn = slime
	elif type == "Mino":
		enemy_spawn = mino
	elif type == "Batsquito":
		enemy_spawn = batsquito
	elif type == "Deer":
		enemy_spawn = deer
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
	Logger.info("Item Dropped | Item ID: %d | Tagged By: %d" % [item_id, tagged_by_player])
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

func _input(event):
	if(event.is_action("camera_left")):
		$Camera2D.position.x -= 40
	if(event.is_action("camera_right")):
		$Camera2D.position.x += 40
	if(event.is_action("camera_up")):
		$Camera2D.position.y -= 40
	if(event.is_action("camera_down")):
		$Camera2D.position.y += 40
	if(event.is_action("camera_zoom_in")):
		$Camera2D.zoom.x -= 0.1
		$Camera2D.zoom.y -= 0.1
	if(event.is_action("camera_zoom_out")):
		$Camera2D.zoom.x += 0.1
		$Camera2D.zoom.y += 0.1
