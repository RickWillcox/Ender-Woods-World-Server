extends KinematicBody2D
class_name Enemy

onready var map = get_node("/root/Server/Map")

var status_dict : Dictionary
func set_status_dict(dict):
	status_dict = dict

func take_damage(value : float, _attacker):
	if status_dict == null:
		# something went wrong, the enemy is not registered in the server
		return

	var id = int(get_name())
	if status_dict[ServerData.ENEMY_CURRENT_HEALTH] <= 0:
		pass
	else:
		status_dict[ServerData.ENEMY_CURRENT_HEALTH] = status_dict[ServerData.ENEMY_CURRENT_HEALTH] - value
		if status_dict[ServerData.ENEMY_CURRENT_HEALTH] <= 0:
			queue_free()
			status_dict[ServerData.ENEMY_STATE] = "DEAD"
			map.release_occupied_location(id)
