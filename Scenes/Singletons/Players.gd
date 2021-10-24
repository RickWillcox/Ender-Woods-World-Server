extends Node

var storage = {}
var player_state_collection = {}

func prepare_new_player(player_id):
	storage[player_id] = Player.new()
	storage[player_id].mock_stats()
	#TODO: Fetch player stats, items, data from auth server

func update_or_create_player(player_id, players_node, new_state):
	if player_state_collection.has(player_id): #check if player is in current collection
		if player_state_collection[player_id][ServerData.PLAYER_TIMESTAMP] \
				< new_state[ServerData.PLAYER_TIMESTAMP]: #check if player state is the latest one
			player_state_collection[player_id] = new_state #replace the player state in collection
			update_player(player_id, new_state)
			#Check for leet hacks
	else:
		initialize_player(player_id, players_node, new_state)
		player_state_collection[player_id] = new_state #add player state to the collection

func initialize_player(player_id, world, initial_state):
	var player = storage[player_id]
	player.initialize(initial_state)
	player.register(world)
	storage[player_id] = player
	
func remove_player(player_id):
	if storage.has(player_id):
		(storage[player_id] as Player).remove()
	if player_state_collection.has(player_id):
		storage.erase(player_id)

func update_player(player_id, state):
	(storage[player_id] as Player).update(state)

func get_player_position(player_id):
	if storage.has(player_id):
		return (storage[player_id] as Player).get_position()
	else:
		return null

func get_player(player_id):
	return storage[player_id]
