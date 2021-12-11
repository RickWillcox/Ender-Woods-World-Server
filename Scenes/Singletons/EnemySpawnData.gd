extends Node

var enemy_spawn_data : Dictionary = {
	"area_0" : {
		"enemies" : {
			"Slime" : 1,
			"Mino" : 0.5,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"max_enemies_in_area" : 3,
		"current_enemies_in_area" : 0,
		"respawn_time" : 3,
		"respawn_timer_node" : Timer,
		"total_probabilty_for_enemy_spawn" : 0,
	},
	"area_1" : {
		"enemies" : {
			"Deer" : 1,
			"BatSquito" : 1,
			"Mino" : 1,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"max_enemies_in_area" : 2,
		"current_enemies_in_area" : 0,
		"respawn_time" : 2,
		"respawn_timer_node" : Timer,
		"total_probabilty_for_enemy_spawn" : 0,
	},
	"area_2" : {
		"enemies" : {
			"Mino" : 1,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"max_enemies_in_area" : 4,
		"current_enemies_in_area" : 0,
		"respawn_time" : 4,
		"respawn_timer_node" : Timer,
		"total_probabilty_for_enemy_spawn" : 0,
	},
	
}

func _ready() -> void:
	add_spawn_locations_to_enemy_spawn_data()
	calculate_total_probability_for_enemy_spawn()
	add_respawn_timers()


			
func spawn_enemy(area_name):
	if enemy_spawn_data[area_name].current_enemies_in_area < enemy_spawn_data[area_name].max_enemies_in_area:
		for j in range (enemy_spawn_data[area_name].occupied_locations.size()):
			if enemy_spawn_data[area_name].occupied_locations[j] == false:
				# enemy can be spawned here
				# select random enemy
				var enemy_type = pick_random_enemy(area_name)enemts
				print("%s spawning %s" % [area_name, enemy_type])
				# spawn an enemy in that area
#				spawn_enemy(enemy, enemy_spawn_data[i].spawn_locations[j], enemy_type)
					
#				spawn_enemy(enemy_id, location, type, enemy_list[enemy_id])
					
				#if enemy is spawned break the loop and restart the timer
				#TIMER RESTART HERE
				break

# Adds a timer for each area and start it.
func add_respawn_timers() -> void:
	for area_name in enemy_spawn_data:
		var t := Timer.new()
		enemy_spawn_data[area_name].respawn_timer_node = t
		t.name = str(area_name) + "_timer"
		add_child(t)
		t.connect("timeout", self, "spawn_enemy", [str(area_name)])
		t.start(enemy_spawn_data[area_name].respawn_time)

func start_respawn_timers() -> void:
	pass

func add_spawn_locations_to_enemy_spawn_data() -> void:
	var spawn_location_node = get_node("/root/Server/ServerMap/SpawnLocations")
	var spawn_location_node_areas = spawn_location_node.get_children()
	
	for area_name in enemy_spawn_data:
		for i in range (spawn_location_node_areas.size()):
			var spawn_location_points = spawn_location_node_areas[i].get_children()
			for spawn_point in spawn_location_points:
				enemy_spawn_data[area_name].spawn_locations.append(spawn_point.position)
				enemy_spawn_data[area_name].occupied_locations.append(false)	
	print(enemy_spawn_data)
		
func calculate_total_probability_for_enemy_spawn() -> void:
	var total_probability : float = 0.00
	for area_name in enemy_spawn_data:
		for enemy_name in enemy_spawn_data[area_name].enemies.keys():
			total_probability += enemy_spawn_data[area_name].enemies[enemy_name]
		enemy_spawn_data[area_name].total_probabilty_for_enemy_spawn = total_probability
		total_probability = 0.00

# Takes in the area_name from enemy_spawn_data and returns a random enemy based up on its weighting.		
# afterwards I found a module called rngtools which might be better to do this
func pick_random_enemy(enemy_spawn_data_area_name : String) -> String:
	var chosen_enemy : String = ""
	var sum_total : float = 0.00
	var probability_array : Array = []
	for enemy_name in enemy_spawn_data[enemy_spawn_data_area_name].enemies.keys():
		sum_total += enemy_spawn_data[enemy_spawn_data_area_name].enemies[enemy_name]
		probability_array.append([enemy_name, sum_total])
	randomize()
	var rand_number = rand_range(0, sum_total)
	for enemy in probability_array:
		if enemy[1] >= rand_number:
			chosen_enemy = enemy[0]
			return chosen_enemy
	return chosen_enemy

