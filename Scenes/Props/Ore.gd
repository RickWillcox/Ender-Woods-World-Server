extends StaticBody2D

var respawn_timer_active = false
var status_dict
var attacks_per_player = {}
var time_since_last_attacked = 0
var si = ServerInterface

func _ready():
	# TODO: make this better
	set_status_dict(ServerData.mining_data[name])

func set_status_dict(dict):
	status_dict = dict

func _physics_process(delta):
	if status_dict[si.ACTIVE] == 0:
		if not respawn_timer_active:
			respawn_timer_active = true
			yield(get_tree().create_timer(status_dict[si.RESPAWN]),"timeout")
			respawn_timer_active = false
			status_dict[si.ACTIVE] = 1
			time_since_last_attacked = 0
	else:
		# reset the attack history if node was not interacted with for 10 seconds
		time_since_last_attacked += delta
		if time_since_last_attacked > 10:
			attacks_per_player.clear()

func take_damage(value, player_id):
	if status_dict == null:
		# TODO: log an error, shouldn't happen
		return
	if status_dict[si.ACTIVE] == 1:
		time_since_last_attacked = 0
		if attacks_per_player.has(player_id):
			attacks_per_player[player_id] += value
		else:
			attacks_per_player[player_id] = value
		
		if attacks_per_player[player_id] >= status_dict[si.HITS_HP]:
			#node drops item and goes inactive
			attacks_per_player.clear()
			status_dict[si.ACTIVE] = 0
			status_dict[si.CURRENT_HITS] = 0
		else:
			status_dict[si.CURRENT_HITS] += 1
