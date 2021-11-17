extends Node
class_name Player

var server
var hitbox : StaticBody2D
var si = ServerInterface
var stats : Dictionary = {}
var inventory : Inventory = Inventory.new()
var username : String

var hitbox_scene = preload("res://Scenes/Player/PlayerHitbox.tscn")

func initialize(player_id):
	hitbox = hitbox_scene.instance()
	hitbox.id = player_id
	hitbox.position = Vector2(250, 250) # Spawn point
	hitbox.display("Current health: " + str(stats["current_health"]))
	HubConnection.get_username(player_id)

func register(world):
	world.add_child(hitbox)
	server = world.get_node("/root/Server")

func update(new_state):
  hitbox.position = new_state[si.PLAYER_POSITION]

func remove():
	if hitbox == null:
		Logger.warn("Player disconnected before registering")
	else:
		var player_id = hitbox.id
		server.broadcast_packet(Players.get_players([player_id]),
			si.create_player_despawn_packet(player_id))
		hitbox.queue_free()
		hitbox = null
		HubConnection.save_inventory(player_id, inventory.slots)

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
	Logger.info("Player: Player %d is attempting to move item %d to %d " % [hitbox.id, from, to])
	return inventory.move_items(from, to)

func add_item(item_id : int, slot : int, amount : int = 1) -> bool:
	return inventory.add_item_to_empty_slot(item_id, amount, slot)

func get_item(slot : int):
	if inventory.slots.has(slot):
		return inventory.slots[slot]["item_id"]
	return 0

func get_username():
	return username
	

func can_craft_recipe(recipe_id : int) -> bool:
	var recipe = ItemDatabase.all_recipe_data[recipe_id]
	return inventory.has_materials(recipe["materials"]) and \
			inventory.find_empty_slot() != -1


func craft_recipe(recipe_id : int):
	var recipe = ItemDatabase.all_recipe_data[recipe_id]
	inventory.remove_materials(recipe["materials"])
	return inventory.add_item(recipe["result_item_id"], 1)


func get_initial_inventory_packet():
	var player_id = hitbox.id
	return ServerInterface.create_initial_inventory_packet(player_id,
		get_item(ItemDatabase.Slots.HEAD_SLOT),
		get_item(ItemDatabase.Slots.CHEST_SLOT),
		get_item(ItemDatabase.Slots.LEGS_SLOT),
		get_item(ItemDatabase.Slots.FEET_SLOT),
		get_item(ItemDatabase.Slots.HANDS_SLOT))
