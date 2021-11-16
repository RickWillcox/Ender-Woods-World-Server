extends StaticBody2D
class_name Ore

var respawn_timer_active = false
var status_dict
var attacks_per_player = {}
var time_since_last_attacked = 0
var si = ServerInterface
var ore_type : String
var item_drop_pool : Array
var random_number_ore : int

onready var server_map = get_node("/root/Server/ServerMap")

func _ready():
	# TODO: make this better
	set_status_dict(ServerData.mining_data[name])
	randomize()
	random_number_ore = randi() % 3 + 1

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
			# Drop more than 1 ore
			for i in range(random_number_ore):
				print("Dropping : %d ores" % [random_number_ore])
				#adjust postion a bit randomly so they dont stack on top of each other
				var drop_position = position + Vector2(rand_range(-8,8), rand_range(-8,8))
				server_map.spawn_item_drop(player_id, drop_position, item_drop_pool[0])
				randomize()
				random_number_ore = randi() % 3 + 1
			
		else:
			# Add some variance into the hits needed to mine. will change this later depending on the pickaxe used
			var random_hits = randi() % 10 + 1
			if random_hits > 3:
				status_dict[si.CURRENT_HITS] += 1
			elif random_hits > 1:
				status_dict[si.CURRENT_HITS] += 2
			else:
				status_dict[si.CURRENT_HITS] += 0
