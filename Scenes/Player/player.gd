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
	
func swap_items(from : int, to : int):
	
	# TODO: remove this once client is updated
	if not from in inventory.keys():
		# nothing to do, from needs to be an item
		return
	if not to in inventory.keys():
		# only source item exists, just change its slot
		inventory[to] = inventory[from]
		# this slot is no longer occupied, erase it from dictionary
		inventory.erase(from)
		return
	
	# both items exist, swap them
	var item = inventory[to]
	inventory[to] = inventory[from]
	inventory[from] = item


func move_items(from : int, to : int) -> bool:
	Logger.info("Player: Player %d is attempting to swap item %d to %d in inventory %s" % [hitbox.id, from, to, str(inventory)])
	
	if not from in inventory.keys():
		# nothing to do, from needs to be an item
		return false
	if not to in inventory.keys():
		# only source item exists, just change its slot
		inventory[to] = inventory[from]
		# this slot is no longer occupied, erase it from dictionary
		inventory.erase(from)
		return true
	
	# Case 1: Item id mismatch, just swap them
	if inventory[from]["item_id"] != inventory[to]["item_id"]:
		swap_items(from, to)
		return true
	
	# Case 2: Items have the same IDs
	var item_id = inventory[from]["item_id"]
	var stack_size = int(ItemDatabase.all_item_data[item_id]["stack_size"])
	# Case 2a: target slot is already full, cannot move
	if stack_size <= inventory[to]["amount"]:
		return false
		
	# Case 2b: There is some space left on the stack
	var total_items = inventory[from]["amount"] + inventory[to]["amount"]
	inventory[to]["amount"] = min(stack_size, total_items)
	var leftover = total_items - stack_size
	if leftover <= 0:
		# All items fit into one slot, stack them, free from slot
		inventory.erase(from)
	else:
		# Some items didn't fit. Keep the from slot occupied, modify number of items
		inventory[from]["amount"] = leftover
		
	return true
