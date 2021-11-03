extends Node
class_name Player

var hitbox_scene = preload("res://Scenes/Player/PlayerHitbox.tscn")
var hitbox : StaticBody2D
var si = ServerInterface

var stats = {}
var inventory : Dictionary


func initialize(player_id, init_state):

	hitbox = hitbox_scene.instance()
	hitbox.id = player_id
	hitbox.display("Current health: " + str(stats["current_health"]))

func register(world):
  world.add_child(hitbox)

func update(new_state):
  hitbox.position = new_state[si.PLAYER_POSITION]

func remove():
	hitbox.get_parent().remove_child(hitbox)
	hitbox.queue_free()
	HubConnection.save_inventory(hitbox.id, inventory)

func get_position():
	return hitbox.position

func mock_stats():
	stats["current_health"] = 100
	stats["max_health"] = 100
	stats["attack"] = 150

func take_damage(value):
	var current_health =  stats["current_health"]
	current_health = max(0, current_health - value)
	stats["current_health"] = current_health
	hitbox.display("Current health: " + str(current_health))

func set_inventory(new_inventory):
	inventory = new_inventory
	
func swap_items(from, to):
	print(inventory)
	if not from in inventory.keys():
		# nothing to do, from needs to be an item
		return
	if not to in inventory.keys():
		# only source item exists, just change its slot
		var item_id = inventory[from]["item_id"]
		inventory[to] = { "item_id" : item_id}
		# this slot is no longer occupied, erase it from dictionary
		inventory.erase(from)
		return
	
	# both items exist, swap them
	var item = inventory[to]
	inventory[to] = inventory[from]
	inventory[from] = item
