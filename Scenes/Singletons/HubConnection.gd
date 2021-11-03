extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1912
#var ip = "192.99.247.42"
var ip = "127.0.0.1"
var connected = false

onready var gameserver = get_node("/root/Server")

func _ready():
	ConnectToServer()
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")	
	network.connect("server_disconnected", self, "_server_disconnected")
	
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
		
func ConnectToServer():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)



func _server_disconnected():
	connected = false
	print("Attempting to reconnect to the Authentication Server")
	while not connected:
		yield(get_tree().create_timer(5), "timeout")
		ConnectToServer()
	

func _OnConnectionFailed():	
	connected = false
	print("Failed to connect to the Game Hub server")
	
func _OnConnectionSucceeded():
	connected = true
	GetAllItemsFromDatabase()
	print("Successfully connected to Game Hub server")
#	gameserver.StartServer()

remote func ReceiveLoginToken(token):
	gameserver.expected_tokens.append(token)
	
func SendPlayerTokenToAuthDatabase(player_id, token):
	rpc_id(1, "ReceivePlayerTokenForDatabase", player_id, token)
	
remote func ReceivePlayerInventory(inventory_data, session_token):
	# Session token == player_id
	Players.get_player(session_token).set_inventory(inventory_data)
	gameserver.SendPlayerInventory(inventory_data, session_token)

func GetAllItemsFromDatabase():
	rpc_id(1, "GetAllItemsFromDatabase")
	
remote func ReceiveItemData(all_item_data):
	print(all_item_data)
	ItemDatabase.all_item_data = all_item_data

func save_inventory(session_token, new_inventory):
	rpc_id(1, "update_inventory", session_token, new_inventory)
