extends Node
# This script replaces the majority of the enemy spawning code on ServerMap.gd
# If you add another area to the SpawnLocations node in the editor you MUST add a new area to enemy_spawn_data. This may change later.
# TODO: Make it pick a random spawn point instead of just the first one it finds free in the array

signal spawn_enemy(enemy_id, location, type, status_dict)

# Replacing enemy_list from ServerMap.gd 
var enemies_on_map_dict : Dictionary = {}

# A new dictionary that stores all the relevant data to spawning and respawning enemies. 
# All adjustments to spawning enemies besides spawn location points can be done in the relevant area here.
# The number next to the enemy name is their weighting chance to spawn. eg Slime : 1 and Mino 0.5 gives slime a 2/3 chance to spawn and a Mino 1/3 chance to spawn. Weights are calculated per area
var enemy_spawn_data : Dictionary = {
	"Area_0" : {
		"enemies" : {
			"Slime" : 1,
			"Mino" : 0.5,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"enemy_id_occupied_locations" : [],
		"max_enemies_in_area" : 3,
		"current_enemies_in_area" : 0,
		"respawn_time" : 4,
		"respawn_timer_node" : Timer,
	},
	"Area_1" : {
		"enemies" : {
			"Deer" : 1,
			"Batsquito" : 1,
			"Mino" : 1,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"enemy_id_occupied_locations" : [],
		"max_enemies_in_area" : 3,
		"current_enemies_in_area" : 0,
		"respawn_time" : 2,
		"respawn_timer_node" : Timer,
	},
	"Area_2" : {
		"enemies" : {
			"Mino" : 1,
		},
		"spawn_locations" : [],
		"occupied_locations" : [],
		"enemy_id_occupied_locations" : [],
		"max_enemies_in_area" : 4,
		"current_enemies_in_area" : 0,
		"respawn_time" : 4,
		"respawn_timer_node" : Timer,
	},
}

func _ready() -> void:
	add_spawn_locations_to_enemy_spawn_data()
	add_respawn_timers()
		
func spawn_enemy(area_name):
	if enemy_spawn_data[area_name].current_enemies_in_area < enemy_spawn_data[area_name].max_enemies_in_area:
		for j in range (enemy_spawn_data[area_name].spawn_locations.size()):
			if enemy_spawn_data[area_name].occupied_locations[j] == false:
				var enemy_type : String = pick_random_enemy(area_name)
				var enemy_id : int = get_next_enemy_id()
				var enemy_location : Vector2 = enemy_spawn_data[area_name].spawn_locations[j]
				var enemy_current_health : int = EnemyData.enemies[enemy_type]["MaxHealth"]
				var enemy_max_health : int = EnemyData.enemies[enemy_type]["MaxHealth"]
				enemies_on_map_dict[enemy_id] = {
					ServerInterface.ENEMY_TYPE: enemy_type, 
					ServerInterface.ENEMY_LOCATION : enemy_location, 
					ServerInterface.ENEMY_CURRENT_HEALTH : enemy_current_health, 
					ServerInterface.ENEMY_MAX_HEALTH: enemy_max_health, 
					ServerInterface.ENEMY_STATE: Enemy.State.IDLE,
					ServerInterface.ENEMY_TIME_OUT: 1}
				emit_signal("spawn_enemy", enemy_id, enemy_location, enemy_type, enemies_on_map_dict[enemy_id])
				enemy_spawn_data[area_name].occupied_locations[j] = true
				enemy_spawn_data[area_name].enemy_id_occupied_locations[j] = enemy_id
				enemy_spawn_data[area_name].current_enemies_in_area += 1
				break

	for enemy in enemies_on_map_dict.keys():
		if enemies_on_map_dict[enemy][ServerInterface.ENEMY_STATE] == Enemy.State.DESPAWN:
			if enemies_on_map_dict[enemy][ServerInterface.ENEMY_TIME_OUT] == 0:
				enemies_on_map_dict.erase(enemy)
			else:
				enemies_on_map_dict[enemy][ServerInterface.ENEMY_TIME_OUT] -= 1

# Adds a respawn timer for each area and start it based off the "respawn_time". Allows us to not use timer nodes in the scene tree and not have to adjust any code when we add more spawn points
func add_respawn_timers() -> void:
	for area_name in enemy_spawn_data:
		var t := Timer.new()
		enemy_spawn_data[area_name].respawn_timer_node = t
		t.name = str(area_name) + "_timer"
		add_child(t)
		t.connect("timeout", self, "spawn_enemy", [str(area_name)])
		t.start(enemy_spawn_data[area_name].respawn_time)

# set up the "spawn_locations", "occupied_locations", "enemy_id_occupied_locations" in the enemy_spawn_data dict. This will allow us to directly make changes in the editor like adding a new spawn point node and not have to make any changes to the code
func add_spawn_locations_to_enemy_spawn_data() -> void:
	var spawn_location_node = get_node("/root/Server/ServerMap/SpawnLocations")
	var spawn_location_node_areas : Array = spawn_location_node.get_children()

	for area in spawn_location_node_areas:
		var spawn_location_points : Array = area.get_children()
		for spawn_point in spawn_location_points:
			enemy_spawn_data[area.name].spawn_locations.append(spawn_point.position)
			enemy_spawn_data[area.name].occupied_locations.append(false)
			enemy_spawn_data[area.name].enemy_id_occupied_locations.append(null)

# when an enemy dies it removes it from the "occupied_locations" and "enemy_id_occupied_locations", so we can use those spots again to spawn a new enemy. Also removes 1 from the "current_enemies_in_area"
func open_spawn_location(enemy_id : int):
	for area in enemy_spawn_data:
		var index = enemy_spawn_data[area].enemy_id_occupied_locations.find(enemy_id, 0)
		if index != -1:
			enemy_spawn_data[area].occupied_locations[index] = false
			enemy_spawn_data[area].enemy_id_occupied_locations[index] = null
			enemy_spawn_data[area].current_enemies_in_area -= 1

# Takes in the area_name from enemy_spawn_data and returns a random enemy based up on its weighting.		
# afterwards I found a module called rngtools which might be better to do this but its fine for now
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

# To make sure enemy_id would never be the same as player_id we make enemy_id > player_id
# player_id (rpc sender id) is a signed 32bit positive integer. So bit 32 is always 0 for
# player id
# Therefore all enemy_ids will start by setting bit 32 to 1
var enemy_id_counter = 0
func get_next_enemy_id() -> int:
	enemy_id_counter += 1
	# set the 32nd bit to 1 and limit the value to U32 range
	return (enemy_id_counter | (1 << 31)) & 0xffffffff
