extends Node

var awaiting_verification = {}

onready var main_interface = get_parent()

func _ready():
	NakamaConnection.connect("token_verified", self, "handle_token_verified")

func start(player_id):
	awaiting_verification[player_id] = {"Timestamp": OS.get_unix_time()}
	Players.prepare_new_player(player_id)
	main_interface.fetch_token(player_id)
	
func verify(player_id, token):
	awaiting_verification[player_id]["token"] = token
	NakamaConnection.verify_token(player_id, token)

func handle_token_verified(result, player_id, token):
	if result == false:
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)
	main_interface.return_token_verification_results(player_id, result)
	Logger.info("Token verification result " + str(result) + " for player " + str(player_id))
