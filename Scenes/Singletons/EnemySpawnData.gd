extends Node

# add more a timer for each area (maybe can do this part better)
var area_1_respawn_timer := Timer.new()
var area_2_respawn_timer := Timer.new()
var area_3_respawn_timer := Timer.new()

var area_respawn_timers = [Timer.new(), Timer.new(), Timer.new()]

var enemy_spawn_data : Dictionary = {
	0 : {
		"enemies" : {
			"Slime" : 1,
			"Mino" : 0.5,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"max_enemies_in_area" : 3,
		"current_enemies_in_area" : 0,
		"repawn_timer" : 3,
		"total_probabilty_for_enemy_spawn" : 0,
	},
	1 : {
		"enemies" : {
			"Deer" : 1,
			"BatSquito" : 1,
			"Mino" : 3,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"max_enemies_in_area" : 2,
		"current_enemies_in_area" : 0,
		"repawn_timer" : 3,
		"total_probabilty_for_enemy_spawn" : 0,
	},
	2 : {
		"enemies" : {
			"Mino" : 1,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"max_enemies_in_area" : 4,
		"current_enemies_in_area" : 0,
		"repawn_timer" : 3,
		"total_probabilty_for_enemy_spawn" : 0,
	},
	
}

func _ready() -> void:
	add_spawn_locations_to_enemy_spawn_data()
	calculate_total_probability_for_enemy_spawn()
	pick_random_enemy(2)
#	start_all_respawn_timers()
	for i in range (enemy_spawn_data.size()):
		if enemy_spawn_data[i].current_enemies_in_area < enemy_spawn_data[i].max_enemies_in_area:
			for j in range (enemy_spawn_data[i].occupied_locations.size()):
				if enemy_spawn_data[i].occupied_locations[j] == false:
					# enemy can be spawned here
					# select random enemy
#					var enemy = pick_random_enemy(i)
					
					# spawn an enemy in that area
					spawn_enemy(enemy_spawn_data[i].enemies, enemy_spawn_data[i].spawn_locations[j])
					
					#if enemy is spawned break the loop and restart the timer
					#TIMER RESTART HERE
					break
			
func spawn_enemy(enemy_type, enemy_location : Vector2):
	pass

#func start_all_respawn_timers():
#	for i in range (area_respawn_timers.size()):
#		area_respawn_timers[i].start(enemy_spawn_data[i].respawn_timer)

func add_spawn_locations_to_enemy_spawn_data() -> void:
	var spawn_location_node = get_node("/root/Server/ServerMap/SpawnLocations")
	var spawn_location_node_areas = spawn_location_node.get_children()
	for i in range (spawn_location_node_areas.size()):
		var spawn_location_points = spawn_location_node_areas[i].get_children()
		for spawn_point in spawn_location_points:
			enemy_spawn_data[i].spawn_locations.append(spawn_point.position)
			enemy_spawn_data[i].occupied_locations.append(false)	
		
func get_enemy_names_in_area(area_index : int) -> Array:
	var enemy_names : Array = []
	for enemy_name in enemy_spawn_data[area_index].values()[0]: 
		enemy_names.append(enemy_name)
	return enemy_names

func calculate_total_probability_for_enemy_spawn() -> void:
	var total_probability : float = 0.00
	for i in range (enemy_spawn_data.size()):
		var enemy_names : Array = get_enemy_names_in_area(i)
		for enemy_name in enemy_names:
			total_probability += enemy_spawn_data[i].enemies[enemy_name]
		enemy_spawn_data[i].total_probabilty_for_enemy_spawn = total_probability
		total_probability = 0.00

# Takes in the key from enemy_spawn_data and returns a random enemy based up on its weighting.		
func pick_random_enemy(enemy_spawn_data_key : int) -> String:
	var chosen_enemy : String = ""
	var sum_total : float = 0.00
	var probability_array : Array = []
	var enemy_names : Array = get_enemy_names_in_area(enemy_spawn_data_key) 
	for enemy_name in enemy_names:
		sum_total += enemy_spawn_data[enemy_spawn_data_key].enemies[enemy_name]
		probability_array.append([enemy_name, sum_total])
	randomize()
	var rand_number = rand_range(0, sum_total)
	for enemy in probability_array:
		if enemy[1] >= rand_number:
			chosen_enemy = enemy[0]
			return chosen_enemy
	return chosen_enemy

