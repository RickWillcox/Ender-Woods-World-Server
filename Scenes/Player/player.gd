extends Node
class_name Player

var server
var hitbox : StaticBody2D
var si = ServerInterface
var stats : Dictionary = {}
var inventory : Inventory = Inventory.new()
var username : String

var hitbox_scene = preload("res://Scenes/Player/PlayerHitbox.tscn")

func initialize(player_id, init_state):
	hitbox = hitbox_scene.instance()
	hitbox.id = player_id
	hitbox.display("Current health: " + str(stats["current_health"]))
	HubConnection.get_username(player_id)

func register(world):
	world.add_child(hitbox)
	server = world.get_node("/root/Server")

func update(new_state):
  hitbox.position = new_state[si.PLAYER_POSITION]

func remove():
	hitbox.get_parent().remove_child(hitbox)
	hitbox.queue_free()
	HubConnection.save_inventory(hitbox.id, inventory.slots)

func get_position():
	return hitbox.position

func mock_stats():
	stats["current_health"] = 100
	stats["max_health"] = 100
	stats["attack"] = 150

func take_damage(value, attacker):
	var current_health =  stats["current_health"]
	current_health = max(0, current_health - value)
	stats["current_health"] = current_health
	hitbox.display("Current health: " + str(current_health))
	server.broadcast_packet(Players.get_players(),
		si.create_player_take_damage_packet(attacker, hitbox.id, value))

func set_inventory(new_inventory):
	inventory.update(new_inventory)

func move_items(from : int, to : int) -> bool:
	Logger.info("Player: Player %d is attempting to moove item %d to %d " % [hitbox.id, from, to])
	return inventory.move_items(from, to)

func add_item(item_id : int, slot : int, amount : int = 1) -> bool:
	return inventory.add_item_to_empty_slot(item_id, amount, slot)

func get_item(slot : int):
	if inventory.slots.has(slot):
		return inventory.slots[slot]["item_id"]
	return 0

func get_username():
	return username
	
