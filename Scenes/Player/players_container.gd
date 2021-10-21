extends Node
class_name PlayersContainer

var storage = {}

func create_new_player(player_id, world, initial_state):
	var player = Player.new()
	player.initialize(initial_state)
	player.register(world)
	storage[player_id] = player
	
func remove_player(player_id):
	(storage[player_id] as Player).remove()
	storage.erase(player_id)

func update_player(player_id, state):
	(storage[player_id] as Player).update(state)
