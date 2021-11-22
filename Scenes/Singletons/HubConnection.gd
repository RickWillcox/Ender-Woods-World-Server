extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var gateway_api : MultiplayerAPI = MultiplayerAPI.new()
var port = 1912
#var ip = "192.99.247.42"
var ip = "127.0.0.1"
var connected = false

onready var gameserver = get_node("/root/Server")

func _ready():
	connect_to_server()
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")	
	network.connect("server_disconnected", self, "_server_disconnected")
	
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
		
func connect_to_server():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)



func _server_disconnected():
	connected = false
	Logger.info("Attempting to reconnect to the Authentication Server")
	while not connected:
		yield(get_tree().create_timer(5), "timeout")
		connect_to_server()
	

func _on_connection_failed():	
	connected = false
	Logger.warn("Failed to connect to the Game Hub server")
	
func _on_connection_succeeded():
	connected = true
	rpc_id(1, "get_recipe_database")
	Logger.info("Successfully connected to Game Hub server")


remote func receive_login_token(token):
	gameserver.expected_tokens.append(token)
	
func SendPlayerTokenToAuthDatabase(player_id, token):
	rpc_id(1, "ReceivePlayerTokenForDatabase", player_id, token)
	
remote func receive_player_inventory(inventory_data, session_token):
	# Session token == player_id
	var player_id = session_token
	var player : Player = Players.get_player(session_token)
	if player:
		player.set_inventory(inventory_data)
		gameserver.broadcast_packet(Players.get_players([player_id]),
			player.get_initial_inventory_packet())
	gameserver.send_player_inventory(inventory_data, session_token)

func save_inventory(session_token, new_inventory):
	rpc_id(1, "update_inventory", session_token, new_inventory)

remote func store_username(username : String, session_token : int):
	var player = Players.get_player(session_token)
	if player:
		player.username = username
		Logger.info("Username: %s added" % username)

func get_username(session_token : int):
	rpc_id(1, "get_username", session_token)
	

remote func receive_recipe_database(recipe_database):
	ItemDatabase.all_recipe_data = recipe_database
