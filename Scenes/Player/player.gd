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
		inventory.fit_item(recipe["result_item_id"], 1) == 0


func craft_recipe(recipe_id : int):
	var recipe = ItemDatabase.all_recipe_data[recipe_id]
	inventory.remove_materials(recipe["materials"])
	inventory.add_item(recipe["result_item_id"], 1)


func get_initial_inventory_packet():
	var player_id = hitbox.id
	return ServerInterface.create_initial_inventory_packet(player_id,
		get_item(ItemDatabase.Slots.HEAD_SLOT),
		get_item(ItemDatabase.Slots.CHEST_SLOT),
		get_item(ItemDatabase.Slots.LEGS_SLOT),
		get_item(ItemDatabase.Slots.FEET_SLOT),
		get_item(ItemDatabase.Slots.HANDS_SLOT))

# This is called via rpc or as smelter loop, returns true if smelter is started
func attempt_to_start_smelter() -> bool:
	if inventory.smelter_started:
		return true
		
	var recipe_id = find_recipe_for_smelter()
	if recipe_id != -1:
		start_smelter(recipe_id)
		return true

	return false

func find_recipe_for_smelter() -> int:
	# collect all available materials
	var input_slots = range(
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT,
		ItemDatabase.Slots.COAL_SMELTING_INPUT_SLOT + 1)
	var available_materials = {}
	for slot in input_slots:
		if inventory.slots.has(slot):
			var item_id = inventory.slots[slot]["item_id"]
			var amount = inventory.slots[slot]["amount"]
			if available_materials.has(item_id):
				available_materials[item_id] += amount
			else:
				available_materials[item_id] = amount
				
	var output_slots = range(
		ItemDatabase.Slots.FIRST_SMELTING_OUTPUT_SLOT,
		ItemDatabase.Slots.LAST_SMELTING_OUTPUT_SLOT + 1
	)
	
	# Find a recipe
	for recipe_id in ItemDatabase.all_recipe_data.keys():
		var recipe = ItemDatabase.all_recipe_data[recipe_id]
		var can_make_recipe = true
		for item_id in recipe["materials"].keys():
			# Check if the item is in the input slots
			if not available_materials.has(item_id):
				can_make_recipe = false
				break
				
			# check if there is enough of the item
			if recipe["materials"][item_id] > available_materials[item_id]:
				can_make_recipe = false
				break
				
		# check if the recipe result can fit into output
		if inventory.fit_item(recipe["result_item_id"], 1, output_slots) != 0:
			can_make_recipe = false

		if can_make_recipe:
			return recipe_id
	return -1


var timer : Timer = null
var smelter_recipe_id = -1
func start_smelter(recipe_id):
	inventory.smelter_started = true
	smelter_recipe_id = recipe_id
	timer = Timer.new()
	timer.wait_time = 5
	timer.autostart = true
	timer.one_shot = true
	timer.connect("timeout", self, "craft_smelting_recipe")
	hitbox.add_child(timer)


func stop_smelter():
	inventory.smelter_started = false
	smelter_recipe_id = -1
	if timer != null:
		timer.stop()
		timer.queue_free()
		timer = null

# Executed via timer
func craft_smelting_recipe():
	var input_slots = range(
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT,
		ItemDatabase.Slots.COAL_SMELTING_INPUT_SLOT + 1)
	var output_slots = range(
		ItemDatabase.Slots.FIRST_SMELTING_OUTPUT_SLOT,
		ItemDatabase.Slots.LAST_SMELTING_OUTPUT_SLOT + 1)
	if smelter_recipe_id != -1:
		var recipe = ItemDatabase.all_recipe_data[smelter_recipe_id]
		var affected_slots = inventory.remove_materials(recipe["materials"], input_slots)
		for slot in affected_slots:
			var item_id = 0
			var amount = 0
			if inventory.slots.has(slot):
				item_id = inventory.slots[slot]["item_id"]
				amount = inventory.slots[slot]["amount"]
			
			server.send_packet(hitbox.id,
					si.create_inventory_slot_update_packet(
						slot,
						item_id,
						amount))
				
		var affected_slot = inventory.add_item(recipe["result_item_id"], 1, output_slots)[0]
		server.send_packet(hitbox.id,
			si.create_inventory_slot_update_packet(
				affected_slot,
				inventory.slots[affected_slot]["item_id"],
				inventory.slots[affected_slot]["amount"]))
		inventory.smelter_started = false
		var restart = attempt_to_start_smelter()
		if not restart:
			server.send_packet(hitbox.id, si.create_smelter_stopped_packet())
