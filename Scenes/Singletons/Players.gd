extends Node

var storage = {}
var player_state_collection = {}

func prepare_new_player(player_id):
	Logger.info("%s: Prepared player %d" % [name, player_id])
	storage[player_id] = Player.new()
	storage[player_id].mock_stats()
	#TODO: Fetch player stats, items, data from auth server

func update_or_create_player(player_id, players_node, new_state):
	if player_state_collection.has(player_id): #check if player is in current collection
		if player_state_collection[player_id][ServerInterface.PLAYER_TIMESTAMP] \
				< new_state[ServerInterface.PLAYER_TIMESTAMP]: #check if player state is the latest one
			player_state_collection[player_id] = new_state #replace the player state in collection
			update_player(player_id, new_state)
			#Check for leet hacks
	else:
		initialize_player(player_id, players_node, new_state)
		player_state_collection[player_id] = new_state #add player state to the collection

func initialize_player(player_id, world, initial_state):
	var player = storage[player_id]
	player.initialize(player_id, initial_state)
	player.register(world)
	storage[player_id] = player
	
func remove_player(player_id):
	if storage.has(player_id):
		(storage[player_id] as Player).remove()
		storage.erase(player_id)
	if player_state_collection.has(player_id):
		player_state_collection.erase(player_id)

func update_player(player_id, state):
	var player : Player = get_player(player_id)
	if player:
		player.update(state)

func get_player_position(player_id):
	var player : Player = get_player(player_id)	
	if player:
		return player.get_position()
	return null

func get_player(player_id):
	if storage.has(player_id):
		return storage[player_id]
	Logger.warn("%s: Attempt to get a non-existing player %d" % [name, player_id])
	return null

func get_players(exclude_list = []):
	var res : Array = []
	for player_id in storage:
		if not player_id in exclude_list:
			res.append(player_id)
	return res

func get_initial_inventory_packet(player_id):
	var player = storage[player_id]
	return ServerInterface.create_initial_inventory_packet(player_id,
		player.get_item(ItemDatabase.Slots.HEAD_SLOT),
		player.get_item(ItemDatabase.Slots.CHEST_SLOT),
		player.get_item(ItemDatabase.Slots.LEGS_SLOT),
		player.get_item(ItemDatabase.Slots.FEET_SLOT),
		player.get_item(ItemDatabase.Slots.HANDS_SLOT))

