extends Node

var storage = {}
var player_state_collection = {}

func prepare_new_player(player_id):
	Logger.info("%s: Prepared player %d" % [name, player_id])
	storage[player_id] = Player.new()
	storage[player_id].mock_stats()

func update_player(player_id, new_state):
	if player_state_collection.has(player_id): #check if player is in current collection
		if player_state_collection[player_id][ServerInterface.PLAYER_TIMESTAMP] \
				< new_state[ServerInterface.PLAYER_TIMESTAMP]: #check if player state is the latest one
			player_state_collection[player_id] = new_state #replace the player state in collection
			_update_player(player_id, new_state)
			#Check for leet hacks
			
func initialize_player(player_id, world):
	var player = storage[player_id]
	player.initialize(player_id)
	player.register(world)
	storage[player_id] = player
	player_state_collection[player_id] = {
		ServerInterface.PLAYER_ANIMATION_VECTOR : Vector2(),
		ServerInterface.PLAYER_POSITION : player.get_position(),
		ServerInterface.PLAYER_TIMESTAMP : 0 }
	
func remove_player(player_id):
	if storage.has(player_id):
		var player : Player = storage[player_id]

		# set user inventory 
		var set_player_inventory : NakamaRequest = NakamaRequest.new()
		add_child(set_player_inventory)
		set_player_inventory.connect("request_completed", self, "_on_set_player_data_completed")
		set_player_inventory.request(
			"set_player_inventory",
			{
				"user_id" : player.user_id,
				"inventory": player.inventory.slots,
			})		
		
		
		# set player stats
		var set_player_stats : NakamaRequest = NakamaRequest.new()
		add_child(set_player_stats)
		set_player_stats.connect("request_completed", self, "_on_set_player_data_completed")
		set_player_stats.request(
			"set_player_stats",
			{
				"user_id" : player.user_id,
				"player_stats" : {
					"experience": player.experience,
					"current_health": player.current_health
				}
			})
		
		# set user Quest States
		var set_player_quests : NakamaRequest = NakamaRequest.new()
		add_child(set_player_quests)
		set_player_quests.connect("request_completed", self, "_on_set_player_data_completed")
		#TODO implement proper tracking of quests

		set_player_quests.request(
			"set_player_quests",
			{
				"user_id" : player.user_id,
				"quest_states": player.get_quests()
			})
		
		player.remove()		
		storage.erase(player_id)
	if player_state_collection.has(player_id):
		player_state_collection.erase(player_id)


func _update_player(player_id, state):
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

func get_spawn_packet(player_id):
	var player = storage[player_id]
	# TODO: Change username
	return ServerInterface.create_player_spawn_packet(player_id,
		player.get_position(), "username")

func get_initial_inventory_packet(player_id):
	var player = storage[player_id]
	return (player as Player).get_initial_inventory_packet()


func _on_set_player_data_completed(input_data, output_data, request : NakamaRequest):
	# Current dont care if it fails. NakamaRequest would crash the server if it
	# does. TODO: Some error handling
	request.queue_free()
