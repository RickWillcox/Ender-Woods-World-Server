extends KinematicBody2D
class_name Enemy

var si = ServerInterface

enum State {
	IDLE,
	WANDER,
	CHASE,
	ATTACK,
	ATTACK_COOLDOWN,
	EVADE,
	DEAD,
	DESPAWN
}

onready var map = get_node("/root/Server/Map")

var status_dict : Dictionary
func set_status_dict(dict):
	status_dict = dict

func take_damage(value : float, _attacker):
	if status_dict == null:
		# something went wrong, the enemy is not registered in the server
		return

	if status_dict[si.ENEMY_CURRENT_HEALTH] <= 0:
		pass
	else:
		status_dict[si.ENEMY_CURRENT_HEALTH] -= value
		if status_dict[si.ENEMY_CURRENT_HEALTH] <= 0:
			enter_state(State.DEAD)

func enter_state(new_state, extra_data = null):
	# Implement in subclasses
	assert(false)
