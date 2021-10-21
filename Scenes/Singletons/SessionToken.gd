extends Node

#When a player connects to the world server generate a session token for that player, send it back to the player and the 
#authentication database, then when a player makes an action that needs to be verified like adding an item to the inventory
#make sure the session tokens match.

func GenerateSessionToken(username, player_id):
	var session_token = str(OS.get_system_time_msecs() + int(username)).sha256_text()
	print("Player_id: ", username)
	print("Session Token: ", session_token)
	HubConnection.SendSessionToken(username, session_token, player_id)
#	GamerServer.
