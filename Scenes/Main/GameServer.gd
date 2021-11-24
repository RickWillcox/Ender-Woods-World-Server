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


onready var players_node = $ServerMap/YSort/Players

# for debugging. To see if we already sent the packets for current frame
var packets_sent = false

var si = ServerInterface

func _ready():
	OS.set_window_position(Vector2(0,0))
	Logger.info("%s: Ready function called" % filename)
	NakamaConnection.get_item_database()
	NakamaConnection.get_recipe_database()
	start_server()
	Logger.info("%s: finished Client>World Server function" % filename)
	
	# to make sure we do packet sending at the end of frame
	process_priority = 3000


func start_server():
	Logger.info("%s: Start server called" % filename)
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	Logger.info("%s: World Server Starting" % filename)

	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")	

#This is set to 20 fps
func _physics_process(delta: float) -> void:
	send_all_packets()
	packets_sent = true
	yield(get_tree(), "idle_frame")
	packets_sent = false

func _peer_connected(player_id):
	Logger.info("%s: User %d connected" % [filename, player_id])
	player_verification_process.start(player_id)
  
func _peer_disconnected(player_id):
	Logger.info("%s: User %d disconnected" % [filename, player_id])
	Players.remove_player(player_id)
	
#Attacking
remote func melee_attack(blend_position):
	var player_id = get_tree().get_rpc_sender_id()
	var player = Players.get_player(player_id)
	if player:
		var player_position = (player as Player).get_position()
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
	rpc_id(player_id, "return_token_verification_results", result)
	if result == true:
		rpc_id(player_id, "get_items_on_ground", get_node("ServerMap").get_items_on_ground())
		
		Players.initialize_player(player_id, get_node("ServerMap/YSort/Players"))
		
		# Spawn all enemies for the player that just connected
		for packet in get_node("ServerMap").get_enemy_state_packets():
			send_packet(player_id, packet)
			
		for other_player_id in Players.get_players([player_id]):
			# spawn other players for player that just connected
			send_packet(player_id, Players.get_spawn_packet(other_player_id))
	
			# Send initial inventory of connected players
			send_packet(player_id, Players.get_initial_inventory_packet(other_player_id))
			
			# inform other players of this new player
			send_packet(other_player_id, Players.get_spawn_packet(player_id))

remote func fetch_player_stats():
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	rpc_id(player_id, "return_player_stats", player_stats)

remote func receive_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	Players.update_player(player_id, player_state)

func send_world_state(world_state): #in case of maps or chunks you will want to track player collection and send accordingly
	rpc_unreliable_id(0, "receive_world_state", world_state)

func enemy_attack(enemy_id, attack_type):
	rpc_id(0, "receive_enemy_attack", enemy_id, attack_type)

func send_player_inventory(inventory_data, session_token):
	var player_id = session_token
	rpc_id(player_id, "receive_player_inventory", inventory_data)

remote func move_items(from, to):
	var player_id = get_tree().get_rpc_sender_id()
	var player : Player = Players.get_player(player_id)
	if player:
		if player.move_items(from, to):
			send_packet(player_id, si.create_inventory_ok_packet())
			
			# Update "to" slot for other players if needed
			if to in [ItemDatabase.Slots.HEAD_SLOT, ItemDatabase.Slots.CHEST_SLOT, ItemDatabase.Slots.FEET_SLOT,
					ItemDatabase.Slots.LEGS_SLOT, ItemDatabase.Slots.HANDS_SLOT]:
				var item_id = player.inventory.slots[to]["item_id"]
				broadcast_packet(Players.get_players([player_id]),
						si.create_inventory_update_packet(player_id, to, item_id))
						
			# Update "from" slot for other players if needed
			if from in [ItemDatabase.Slots.HEAD_SLOT, ItemDatabase.Slots.CHEST_SLOT, ItemDatabase.Slots.FEET_SLOT,
					ItemDatabase.Slots.LEGS_SLOT, ItemDatabase.Slots.HANDS_SLOT]:
						
				# from can be empty
				var item_id = 0
				if player.inventory.slots.has(from):
					item_id = player.inventory.slot[from]["item_id"]
				broadcast_packet(Players.get_players([player_id]),
						si.create_inventory_update_packet(player_id, from, item_id))
			return
	send_packet(player_id, si.create_inventory_nok_packet())

func add_item_drop_to_client(item_id : int, item_name : String, item_position : Vector2, tagged_by_player : int):
	rpc_id(0, "add_item_drop_to_client", item_id, item_name, item_position,tagged_by_player)
	
func remove_item_drop_from_client(item_name):
	broadcast_packet(Players.get_players(), si.create_remove_item_packet(int(item_name)))

remote func pickup_item(item_drop_id : int, amount : int):
	var player_id = get_tree().get_rpc_sender_id()
	Logger.info("Pickup item %d to player %d, slot %d" % [item_drop_id, player_id, amount])
	var player : Player = Players.get_player(player_id)
	if player:
		# Find item on server
		var target_item = null
		for item in server_map.get_node("YSort/Items").get_children():
			if item.name == str(item_drop_id):
				target_item = item
				break
		if target_item == null:
			send_packet(player_id, si.create_inventory_nok_packet())
			return
			
		# Check if player is in range to pick up item
		if target_item.player_in_range_of_item(player_id):
			# Check if player can pickup item	
			if not target_item.anyone_pick_up and player_id != target_item.tagged_by_player:
				# attempt to take item that doesnt belong to player
				send_packet(player_id, si.create_inventory_nok_packet())
				return
			
			# Check if the items fit backpack
			if player.inventory.fit_item(target_item.item_id, amount) != 0:
				send_packet(player_id, si.create_inventory_nok_packet())
				return
			
			# All conditions met, add items
			player.inventory.add_item(target_item.item_id, amount) 
			send_packet(player_id, si.create_inventory_ok_packet())
			target_item.queue_free()
			return
	send_packet(player_id, si.create_inventory_nok_packet())

var packets_to_send = {}
func send_packet(player_id, data):
	if packets_sent:
		Logger.warn("Packet to player %d sent too late, will be delayed by one frame: %s" % [player_id, str(data)] )
	enqueue_packet(player_id, data)	

# Send packet to many players	
func broadcast_packet(player_ids : Array, data):
	for player_id in player_ids:
		send_packet(player_id, data)

func enqueue_packet(player_id, data):
	if packets_to_send.has(player_id):
		packets_to_send[player_id].append(data)
	else:
		packets_to_send[player_id] = [data]
		
func send_all_packets():
	for player_id in packets_to_send:
		# check if player is connected
		if Players.get_player(player_id):
			var packet_bundle = Serializer.PacketBundle.new()
			packet_bundle.serialize_packets(packets_to_send[player_id],
				Serializer.get_server_client_descriptor())
			var size = packet_bundle.buffer.size()
			if size > 50:
				packet_bundle.compress()
				rpc_id(player_id, "handle_compressed_input_packets", packet_bundle.buffer, size)
			else:
				rpc_id(player_id, "handle_uncompressed_input_packets", packet_bundle.buffer)
			packet_bundle.free()
	packets_to_send = {}

remote func receive_player_chat(text : String):
	var player_id : int = get_tree().get_rpc_sender_id()
	var player : Player = Players.get_player(player_id)
	if player:
#		var username_chat : String = "%s: %s" % [player.get_username(), text]
#		broadcast_packet(Players.get_players([player_id]), si.create_player_chat_packet(player_id, username_chat))
		rpc_id(0, "receive_player_chat", player_id, player.get_username(), text)


remote func craft_recipe(recipe_id : int):
	var player_id = get_tree().get_rpc_sender_id()
	var player : Player = Players.get_player(player_id)
	if player:
		if  ItemDatabase.all_recipe_data.has(recipe_id) and player.can_craft_recipe(recipe_id):
			var item_id = ItemDatabase.all_recipe_data[recipe_id]["result_item_id"]
			var slot = player.craft_recipe(recipe_id)
			send_packet(player_id, si.create_item_craft_ok_packet(slot, item_id))
			return
	send_packet(player_id, si.create_item_craft_nok_packet())

remote func start_smelter():
	var player_id = get_tree().get_rpc_sender_id()
	var player : Player = Players.get_player(player_id)
	if player:
		
		# its already started
		if player.inventory.smelter_started:
			send_packet(player_id, si.create_smelter_started_packet())
			return
			
		# attempt to start by finding a recipe
		var smelter_started = player.attempt_to_start_smelter()
		if smelter_started:
			send_packet(player_id, si.create_smelter_started_packet())
			return
	send_packet(player_id, si.create_smelter_stopped_packet())


remote func stop_smelter():
	var player_id = get_tree().get_rpc_sender_id()
	var player : Player = Players.get_player(player_id)
	if player:
		if player.inventory.smelter_started:
			player.stop_smelter()
	send_packet(player_id, si.create_smelter_stopped_packet())
