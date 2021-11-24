extends Node

signal token_verified(result, player_id, token)
# this implements connection to nakama REST API

var ip_port = "127.0.0.1:7350"
# this is like the password for our API. Should be made more secure
# to prevent cheating by calling our APIs
var http_key = "defaulthttpkey"

func get_item_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_http_request_completed")
	var error = request.request("http://" + ip_port + "/v2/rpc/get_items?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	yield(self, "http_ok")
	request.queue_free()
	
	var data = JSON.parse(http_response["payload"]).result
	assert(data["success"] == true)
	Logger.info("Received item data from Nakama server")
	
	ItemDatabase.all_item_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_item_data)

func get_recipe_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_http_request_completed")
	var error = request.request("http://" + ip_port + "/v2/rpc/get_recipes?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	yield(self, "http_ok")
	request.queue_free()
	
	var data = JSON.parse(http_response["payload"]).result
	assert(data["success"] == true)
	Logger.info("Received recipes data from Nakama server")
	
	ItemDatabase.all_recipe_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_recipe_data)
	
func verify_token(player_id, token):
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_http_request_completed")
	var error = request.request(
		"http://127.0.0.1:7350/v2/rpc/check_auth",
		["Authorization: Bearer " + token])
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		emit_signal("token_verified", false, player_id, token)
	
	yield(self, "http_ok")
	var result = JSON.parse(http_response["payload"]).result
	assert(result["success"] == true)
	request.queue_free()
	emit_signal("token_verified", true, player_id, token)
	var player : Player = Players.get_player(player_id)
	if player:
		player.username = result["username"]
		player.user_id = result["user_id"]


func save_inventory(uuid, new_inventory):
	pass
	
func get_inventory(uuid):
	pass

signal http_ok
var http_response
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	http_response = response
	emit_signal("http_ok")
