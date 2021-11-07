###############################################
#        World Server Start 
#		 Connections: Client    
#        port 1909                        
###############################################


extends Node

onready var player_verification_process = get_node("PlayerVerification")
onready var server_map = get_node("ServerMap")
onready var state_processing = get_node("StateProcessing")

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

var expected_tokens = []

onready var players_node = $ServerMap/YSort/Players

func _ready():
	OS.set_window_position(Vector2(0,0))
	Logger.info("%s: Ready function called" % filename)
	start_server()
	Logger.info("%s: finished Client>World Server function" % filename)


func start_server():
	Logger.info("%s: Start server called" % filename)
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	Logger.info("%s: World Server Starting" % filename)

	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")	

func _process(_delta: float) -> void:
	pass
  
func _peer_connected(player_id):
	Logger.info("%s: User %d connected" % [filename, player_id])
	player_verification_process.start(player_id)
  
func _peer_disconnected(player_id):
	Logger.info("%s: User %d disconnected" % [filename, player_id])
	Players.remove_player(player_id)
	rpc_id(0, "despawn_player", player_id)
	
#Attacking
remote func melee_attack(blend_position):
	var player_id = get_tree().get_rpc_sender_id()
	var player_position = state_processing.world_state()[player_id]["P"]
	server_map.use_melee_attack(player_id, blend_position, player_position)
	
remote func fetch_server_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_system_time_msecs(), client_time)	

remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_latency", client_time)

func fetch_token(player_id):
	rpc_id(player_id, "fetch_token")
  
remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.verify(player_id, token)

func return_token_verification_results(player_id : int, result : bool):
	rpc_id(player_id, "return_token_verification_results", result, ItemDatabase.all_item_data)
	if result == true:
		rpc_id(0, "spawn_new_player", player_id, Vector2(450, 220))
		rpc_id(player_id, "get_items_on_ground", get_node("ServerMap").get_items_on_ground())
		rpc_id(player_id, "store_player_id", player_id)

remote func fetch_player_stats():
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	rpc_id(player_id, "return_player_stats", player_stats)

func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)

remote func receive_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	Players.update_or_create_player(player_id, players_node, player_state)

func send_world_state(world_state): #in case of maps or chunks you will want to track player collection and send accordingly
	rpc_unreliable_id(0, "receive_world_state", world_state)

func enemy_attack(enemy_id, attack_type):
	rpc_id(0, "receive_enemy_attack", enemy_id, attack_type)

func send_player_inventory(inventory_data, session_token):
	rpc_id(session_token, "receive_player_inventory", inventory_data)

# swap two locations in inventory
remote func swap_items(from, to):
	var player_id = get_tree().get_rpc_sender_id()
	var player : Player = Players.get_player(player_id)
	if player:
		player.swap_items(from, to)
	rpc_id(player_id, "item_swap_ok")
	

remote func move_items(from, to):
	var player_id = get_tree().get_rpc_sender_id()
	var player : Player = Players.get_player(player_id)
	if player:
		if player.move_items(from, to):
			rpc_id(player_id, "item_swap_ok")
			return
	rpc_id(player_id, "item_swap_nok")

func add_item_drop_to_client(item_id : int, item_name : String, item_position : Vector2, tagged_by_player : int):
	rpc_id(0, "add_item_drop_to_client", item_id, item_name, item_position,tagged_by_player)

	
func remove_item_drop_from_client(item_name):
	rpc_id(0, "remove_item_drop_from_client", item_name)

remote func add_item(action_id : String, slot : int):
	var player_id = get_tree().get_rpc_sender_id()
	Logger.info("Add item %s to player %d, slot %d" % [action_id, player_id, slot])
	var player : Player = Players.get_player(player_id)
	if player:
		
		# Find item on server
		var target_item = null
		for item in server_map.get_node("YSort/Items").get_children():
			if item.name == action_id:
				target_item = item
				break
		
		# Check if player can pickup item		
		if not target_item.anyone_pick_up and player_id != target_item.tagged_by_player:
			# attempt to take item that doesnt belong to player
			rpc_id(player_id, "item_add_nok")
			return
		
		# add item to player inventory
		if player.add_item(target_item.item_id, slot):
			rpc_id(player_id, "item_swap_ok")
			target_item.queue_free()
			return
	rpc_id(player_id, "item_swap_nok")
