extends Node

#When a player connects to the world server generate a session token for that player, send it back to the player and the 
#authentication database, then when a player makes an action that needs to be verified like adding an item to the inventory
#make sure the session tokens match.

func GenerateSessionToken(player_id):
	var session_token = str(OS.get_system_time_msecs() + int(player_id)).sha256_text()
	print("Player_id: ", player_id)
	print("Session Token: ", session_token)
	get_node("/root/Server").SendClientSessionToken(session_token, player_id)
