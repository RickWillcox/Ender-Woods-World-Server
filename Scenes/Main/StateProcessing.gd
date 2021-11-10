extends Node

var si = ServerInterface
var world_state = {}

func _physics_process(_delta):
	if not Players.player_state_collection.empty():
		world_state = Players.player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase(si.TIMESTAMP) #player time stamp not important save bytes
		world_state[si.TIMESTAMP] = OS.get_system_time_msecs()
		world_state[si.ENEMIES] = get_node("../ServerMap").enemy_list #E: Enemies
		world_state[si.ORES] = get_node("../ServerMap").ore_list #O: Ores
		#Verification
		#anti cheat
		#cuts
		#physics checks
		get_parent().send_world_state(world_state)


# warning-ignore:function_conflicts_variable
func world_state():
	return world_state
