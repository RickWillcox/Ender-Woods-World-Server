extends Node

signal token_verified(result, player_id, token)
# this implements connection to nakama REST API

var ip_port = "127.0.0.1:7350"
# this is like the password for our API. Should be made more secure
# to prevent cheating by calling our APIs
var http_key = "defaulthttpkey"

# Item Database
func get_items_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_handle_items_database_received", [request])
	var error = request.request("http://" + ip_port + "/v2/rpc/get_items_database?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		assert(false)

func _handle_items_database_received(result, response_code, headers, body, request : HTTPRequest):
	var response = parse_json(body.get_string_from_utf8())	
	var data = JSON.parse(response["payload"]).result
	request.queue_free()
	assert(data["success"] == true)
	Logger.info("Received ITEMS DATABASE from Nakama server")
	ItemDatabase.all_item_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_item_data)

# Crafting Recipes Database
func get_crafting_recipes_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_handle_crafting_recipes_database_received", [request])
	var error = request.request("http://" + ip_port + "/v2/rpc/get_crafting_recipes_database?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		assert(false)

func _handle_crafting_recipes_database_received(result, response_code, headers, body, request : HTTPRequest):
	var response = parse_json(body.get_string_from_utf8())	
	request.queue_free()
	var data = JSON.parse(response["payload"]).result
	assert(data["success"] == true)
	Logger.info("Received CRAFTING RECIPES DATABASE from Nakama server")
	
	ItemDatabase.all_recipe_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_recipe_data)

# Item Modifier Database
func get_item_modifiers_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_handle_item_modifiers_database_received", [request])
	var error = request.request("http://" + ip_port + "/v2/rpc/get_item_modifiers_database?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		assert(false)
		
func _handle_item_modifiers_database_received(result, response_code, headers, body, request : HTTPRequest):
	var response = parse_json(body.get_string_from_utf8())	
	var data = JSON.parse(response["payload"]).result
	request.queue_free()
	assert(data["success"] == true)
	Logger.info("Received ITEM MODIFIERS DATABASE from Nakama server")
	
	# TODO use the item modifiers data received

# Quests Database
func get_quests_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_handle_quests_database_received", [request])
	var error = request.request("http://" + ip_port + "/v2/rpc/get_quests_database?http_key=" + http_key)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		assert(false)	

func _handle_quests_database_received(result, response_code, headers, body, request : HTTPRequest):
	var response = parse_json(body.get_string_from_utf8())	
	var all_quest_data = JSON.parse(response["payload"]).result
	request.queue_free()
	assert(all_quest_data["success"] == true)
	Logger.info("Received QUEST DATABASE from Nakama server")
	# TODO use the quest data received
	AllQuests.set_all_quests(all_quest_data["result"])
	
# Verify Token	
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

func _handle_verify_token_response(result, response_code, headers, body, request : HTTPRequest, player_id : int, token : String):
	Logger.info("Verify token response result: %s, response_code: %s, headers: %s, body: %s, token: %s" %
		[str(result), str(response_code), str(headers), str(body), token])
	var response = parse_json(body.get_string_from_utf8())
	print(response)
	var data = JSON.parse(response["payload"]).result
	assert(data["success"] == true)
	request.queue_free()
	var player : Player = Players.get_player(player_id)
	if player:
#		player.experience = data["gamedata"]["experience"]
#		player.current_health = data["gamedata"]["current_health"]
		player.username = data["username"]
		player.user_id = data["user_id"]

	emit_signal("token_verified", true, player_id, token)
