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
	request.connect("request_completed", self, "_handle_item_db_received", [request])
	var error = request.request("http://" + ip_port + "/v2/rpc/get_items?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		assert(false)

func get_recipe_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_handle_recipe_db_received", [request])
	var error = request.request("http://" + ip_port + "/v2/rpc/get_recipes?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		assert(false)
	
func verify_token(player_id, token):
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_handle_verify_token_response", [request, player_id, token])
	var error = request.request(
		"http://127.0.0.1:7350/v2/rpc/check_auth",
		["Authorization: Bearer " + token])
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		emit_signal("token_verified", false, player_id, token)


func save_inventory(uuid, new_inventory):
	pass
	
func get_inventory(uuid):
	pass

func _handle_recipe_db_received(result, response_code, headers, body, request : HTTPRequest):
	var response = parse_json(body.get_string_from_utf8())	
	request.queue_free()
	var data = JSON.parse(response["payload"]).result
	assert(data["success"] == true)
	Logger.info("Received recipes data from Nakama server")
	
	ItemDatabase.all_recipe_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_recipe_data)

func _handle_item_db_received(result, response_code, headers, body, request : HTTPRequest):
	var response = parse_json(body.get_string_from_utf8())	
	var data = JSON.parse(response["payload"]).result
	request.queue_free()
	assert(data["success"] == true)
	Logger.info("Received item data from Nakama server")
	
	ItemDatabase.all_item_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_item_data)


func _handle_verify_token_response(result, response_code, headers, body, request : HTTPRequest, player_id : int, token : String):
	var response = parse_json(body.get_string_from_utf8())
	var data = JSON.parse(response["payload"]).result
	assert(data["success"] == true)
	request.queue_free()
	emit_signal("token_verified", true, player_id, token)
	var player : Player = Players.get_player(player_id)
	if player:
		player.username = data["username"]
		player.user_id = data["user_id"]
