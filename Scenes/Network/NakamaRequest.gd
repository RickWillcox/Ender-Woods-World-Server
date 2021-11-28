extends Node
class_name NakamaRequest
# this node emulates httprequest but with much smaller scope - only sending HTTP
# requests towards nakama server

var ip_port = "127.0.0.1:7350"
var http_key = "defaulthttpkey"

signal request_completed(input_data, output_data, request)

func request(rpc_name : String, input_data : Dictionary = {}):
	var method : int = HTTPClient.METHOD_GET
	var request_data : String = ""
	if not input_data.empty():
		method = HTTPClient.METHOD_POST
		request_data = JSON.print(JSON.print(input_data))
		
	var request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self, "_handle_request_completed", [request, input_data])
	var error = request.request(
		"http://%s/v2/rpc/%s?http_key=%s" % [ip_port, rpc_name, http_key],
		[],
		true,
		method,
		request_data)
	if error != OK:
		Logger.error("An error occurred in the HTTP request")
		assert(false)


func _handle_request_completed(result, response_code, headers, body, request : HTTPRequest, input_data):
	var response = parse_json(body.get_string_from_utf8())
	var output_data = JSON.parse(response["payload"]).result
	assert(output_data["success"] == true)
	if "result" in output_data:
		Utils.convert_keys_to_int(output_data["result"])
	request.queue_free()
	emit_signal("request_completed", input_data, output_data, self)
