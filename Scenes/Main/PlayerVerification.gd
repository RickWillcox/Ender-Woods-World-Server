extends Node

var awaiting_verification = {}

onready var main_interface = get_parent()

func start(player_id):
	#16:13 #6
	awaiting_verification[player_id] = {"Timestamp": OS.get_unix_time()}
	print(awaiting_verification)
	main_interface.fetch_token(player_id)
	
func verify(player_id, token):
	var token_verification = false
	Logger.info("Token Verification- Player ID: %d | Auth Token: %s" % [player_id, token])
	while OS.get_unix_time() - int(token.right(64)) <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			Players.prepare_new_player(player_id)
			awaiting_verification.erase(player_id)
			HubConnection.SendPlayerTokenToAuthDatabase(player_id, token)
			main_interface.expected_tokens.erase(token)
			Logger.warn("Authentication Token Correct for Player ID: %d | Auth Token{5}: %s" % [player_id, token.left(5)])
			break
		else:
			yield(get_tree().create_timer(2), "timeout")
	main_interface.return_token_verification_results(player_id, token_verification)
	if token_verification == false:
		Logger.warn("Authentication Token Incorrect for Player ID: %d | Auth Token{5}: %s" % [player_id, token.left(5)])
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)

func _on_VerificationExpiration_timeout():
	var current_time = OS.get_unix_time()
	var start_time : int
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 60:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(key):
					main_interface.return_token_verification_results(key, false)
					main_interface.network.disconnect_peer(key)
			
