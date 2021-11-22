extends Node

# this implements connection to nakama REST API

var ip_port = "127.0.0.1:7350"
var http_key = "defaultkey"

func get_item_database():
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_http_request_completed")
	var error = request.request("http://" + ip_port + "/v2/rpc/get_items?http_key=defaulthttpkey")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	yield(self, "http_ok")
	request.queue_free()
	
	var data = JSON.parse(http_response["payload"]).result
	assert(data["success"] == true)
	Logger.info("Received item data from Nakama server")
	
	ItemDatabase.all_item_data = {}
	for key in data["result"]:
		ItemDatabase.all_item_data[int(key)] = data["result"][key]
	Logger.info(str(ItemDatabase.all_item_data))


signal http_ok
var http_response
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	http_response = response
	emit_signal("http_ok")
