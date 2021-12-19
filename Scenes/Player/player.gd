extends Node
class_name Player

var server
var world_player : StaticBody2D
var si = ServerInterface
var stats : Dictionary = {}
var inventory : Inventory = Inventory.new()
var player_quests : PlayerQuests = PlayerQuests.new()
var username : String
var user_id : String
var experience : int setget set_experience
var current_health : float setget set_current_health

var world_player_scene = preload("res://Scenes/Player/PlayerHitbox.tscn")

func initialize(player_id):
	world_player = world_player_scene.instance()
	world_player.id = player_id
	world_player.position = Vector2(250, 250) # Spawn point
	mock_stats()
	world_player.display("Current health: " + str(stats["current_health"]))


func set_experience(_experience):
	# TODO: make this part of a "Stat" node, just set the value in the stat
	# node of player and add a getter also
	experience = _experience
	# TODO: Call some function to recalcualte stats
	
func set_current_health(_current_health):
	# TODO: make this part of a "Stat" node, just set the value in the stat
	# node of player and add a getter also
	if _current_health == -1:
		# TODO: set _current_health to max_health, this happens when current 
		# health is uninitialized: player just started the game or some reset
		# conditions in the future
		# To test out gamedata saving
		_current_health = 100
	current_health = _current_health
	# TODO: Check if player died. Perform on death actions


func register(world):
	world.add_child(world_player)
	server = world.get_node("/root/Server")

func update(new_state):
  world_player.position = new_state[si.PLAYER_POSITION]

func remove():
	if world_player == null:
		Logger.warn("Player disconnected before registering")
	else:
		var player_id = world_player.id
		server.broadcast_packet(Players.get_players([player_id]),
			si.create_player_despawn_packet(player_id))
		world_player.queue_free()
		world_player = null

func get_position():
	return world_player.position

func mock_stats():
	stats["current_health"] = 100
	stats["max_health"] = 100
	stats["attack"] = 150

func take_damage(damage_value, attacker):
	stats["current_health"] -= damage_value
	world_player.display("Current health: %d" % [stats["current_health"]])
	server.broadcast_packet(Players.get_players(),
		si.create_player_take_damage_packet(attacker, world_player.id, damage_value))
	if stats["current_health"] <= 0:
		world_player.position = Vector2(250, 250)
		server.broadcast_packet(
			Players.get_players(), # everyone receives the packet
			si.create_player_died_packet(world_player.id, world_player.position))

# This function can be used to initialise the quest state or update any quests, just pass it valid json
func set_quests(current_quests : Dictionary, updated_quests : Dictionary):
	player_quests.set_player_quests(current_quests, updated_quests)
	Logger.info("SET QUESTS! ", player_quests.quests)
		
func get_quests() -> Dictionary:
	Logger.info("GET QUESTS! ", player_quests.quests)
	return player_quests.quests

func set_inventory(new_inventory):
	inventory.update(new_inventory)

func move_items(from : int, to : int) -> bool:
	Logger.info("Player: Player %d is attempting to move item %d to %d " % [world_player.id, from, to])
	
	testing()
	
	return inventory.move_items(from, to)

func testing():
	Logger.info("SETTING NEW QUESTS")
	var current_player_quests = get_quests()
	Logger.info("OLD QUEST DATA: ", current_player_quests)
	set_quests(current_player_quests, {
			1: {
				"kill" : {
					"rock_golem" : 22
				},
				"collect_items" : 1,
				"talk_to_npc" : "jack"
			},
			2: {
				"kill" : {
					"mino" : 50
				},
				"collect_items" : 20,
				"talk_to_npc" : "nick",
				"test" : 11
			},
		})

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
	var player_id = world_player.id
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
	timer.wait_time = 2
	timer.autostart = true
	timer.one_shot = true
	timer.connect("timeout", self, "craft_smelting_recipe")
	world_player.add_child(timer)


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
			
			server.send_packet(world_player.id,
					si.create_inventory_slot_update_packet(
						slot,
						item_id,
						amount))
				
		var affected_slot = inventory.add_item(recipe["result_item_id"], 1, output_slots)[0]
		server.send_packet(world_player.id,
			si.create_inventory_slot_update_packet(
				affected_slot,
				inventory.slots[affected_slot]["item_id"],
				inventory.slots[affected_slot]["amount"]))
		inventory.smelter_started = false
		var restart = attempt_to_start_smelter()
		if not restart:
			server.send_packet(world_player.id, si.create_smelter_stopped_packet())



