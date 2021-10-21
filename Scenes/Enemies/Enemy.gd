extends KinematicBody2D
class_name Enemy

onready var map = get_node("../../../../Map")

var status_dict : Dictionary
func set_status_dict(dict):
	status_dict = dict

func take_damage(value, _attacker):
	var id = int(get_name())
	if status_dict[ServerData.ENEMY_CURRENT_HEALTH] <= 0:
		pass
	else:
		status_dict[ServerData.ENEMY_CURRENT_HEALTH] = status_dict[ServerData.ENEMY_CURRENT_HEALTH] - value
		if status_dict[ServerData.ENEMY_CURRENT_HEALTH] <= 0:
			queue_free()
			status_dict[ServerData.ENEMY_STATE] = "DEAD"
			map.release_occupied_location(id)
