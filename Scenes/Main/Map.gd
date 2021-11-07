extends Node

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
	timer.connect("timeout", self, "spawn_enemy")
	self.add_child(timer)
	
func spawn_enemy():
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
		get_parent().get_node("ServerMap").spawn_enemy(enemy_id_counter, location, type, enemy_list[enemy_id_counter])
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
			

