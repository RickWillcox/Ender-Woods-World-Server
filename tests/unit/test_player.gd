extends "res://addons/gut/test.gd"

func before_all():
	ItemDatabase.all_item_data = {
		ItemDatabase.MaterialItemIds.COPPER_ORE : {
			"stack_size" : 20,
			"item_category" : ItemDatabase.Category.ORE
		},
		ItemDatabase.MaterialItemIds.TIN_ORE : {
			"stack_size" : 20,
			"item_category" : ItemDatabase.Category.ORE
		},
		ItemDatabase.MaterialItemIds.COPPER_BAR : {
			"stack_size" : 20,
			"item_category" : ItemDatabase.Category.METAL_BAR
		},
		ItemDatabase.MaterialItemIds.BRONZE_BAR : {
			"stack_size" : 20,
			"item_category" : ItemDatabase.Category.METAL_BAR
		},
		
	}
	
	ItemDatabase.all_recipe_data = {
		ItemDatabase.RecipeIds.SMELT_COPPER : {
			"materials" : {ItemDatabase.MaterialItemIds.COPPER_ORE : 2},
			"result_item_id" : ItemDatabase.MaterialItemIds.COPPER_BAR
		},
		ItemDatabase.RecipeIds.SMELT_BRONZE : {
			"materials": {
				ItemDatabase.MaterialItemIds.COPPER_ORE: 2,
				ItemDatabase.MaterialItemIds.TIN_ORE : 2
			},
			"result_item_id" : ItemDatabase.MaterialItemIds.BRONZE_BAR
		}
	}

func test_player_new():
	var _player = Player.new()
	assert_true(true)
	
func test_player_inventory():
	var player = Player.new()
	player.set_inventory({17 : {"item_id" : 3, "amount" : 3}} )
	assert_true(player.get_item(17) == 3)

func test_player_can_craft():
	var player = Player.new()
	player.set_inventory({17 : {
		"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 3}} )
	assert_true(player.can_craft_recipe(ItemDatabase.RecipeIds.SMELT_COPPER))

func test_player_craft():
	var result_item_id = ItemDatabase.all_recipe_data[ItemDatabase.RecipeIds.SMELT_COPPER]["result_item_id"]
	
	var player = Player.new()
	player.set_inventory(
		{17 : {"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 1},
		18 : {"item_id" : ItemDatabase.MaterialItemIds.TIN_ORE, "amount" : 1},
		30 : {"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 1},
		31 : {"item_id" : ItemDatabase.MaterialItemIds.TIN_ORE, "amount" : 9}})
	assert_true(player.can_craft_recipe(ItemDatabase.RecipeIds.SMELT_COPPER))
	player.craft_recipe(ItemDatabase.RecipeIds.SMELT_COPPER)
	
	# Check that player has exactly 1 item from recipe
	assert_true(player.inventory.has_items(result_item_id))
	player.inventory.remove_items(result_item_id)
	assert_false(player.inventory.has_items(result_item_id))
	
	# check that corrent number of matetials was removed
	assert_false(player.inventory.has_items(ItemDatabase.MaterialItemIds.COPPER_ORE))
	assert_true(player.inventory.has_items(ItemDatabase.MaterialItemIds.TIN_ORE))
	player.inventory.remove_items(ItemDatabase.MaterialItemIds.TIN_ORE, 10)
	assert_false(player.inventory.has_items(ItemDatabase.MaterialItemIds.TIN_ORE))


func test_player_find_recipe_for_smelter():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 3 }
	})
	assert_eq(player.find_recipe_for_smelter(), 0)
	

func test_player_find_recipe_for_smelter_no_items():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 1 }
	})
	assert_eq(player.find_recipe_for_smelter(), -1)
	
func test_player_find_recipe_for_smelter_complex():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 3
		},
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1: {
			"item_id" : ItemDatabase.MaterialItemIds.TIN_ORE, "amount" : 1
		}
	})
	assert_eq(player.find_recipe_for_smelter(), 0)
	

func test_player_find_recipe_for_smelter_complex_no_items():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 1
		},
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1: {
			"item_id" : ItemDatabase.MaterialItemIds.TIN_ORE, "amount" : 2
		}
	})
	assert_eq(player.find_recipe_for_smelter(), -1)


func test_player_find_recipe_for_smelter_complex_split_slots():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 3
		},
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 1
		}
	})
	assert_eq(player.find_recipe_for_smelter(), 0)


func test_player_add_remove_smelter_items():
	var player = Player.new()
	
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 3
		},
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 1
		}
	})
	
	var smelting_input_slots = [
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT,
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1,
	]
	
	assert_true(
		player.inventory.has_items(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			4,
			smelting_input_slots))
	assert_false(
		player.inventory.has_items(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			4,
			[ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT]))
			
	# always adds to the first slot unless its full
	player.inventory.add_item(ItemDatabase.MaterialItemIds.COPPER_ORE, 2, smelting_input_slots)
	
	assert_eq(
		player.inventory.slots[ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT]["amount"],
		5)
		
	# We can fit another 20 ore:
	assert_eq(
		player.inventory.fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			20,
			smelting_input_slots), 0)
		
	# add 20 ore
	player.inventory.add_item(ItemDatabase.MaterialItemIds.COPPER_ORE, 20, smelting_input_slots)
		
	# first slot has 20 now
	assert_eq(
		player.inventory.slots[ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT]["amount"],
		20)
	
	# second slot has 5 + 1
	assert_eq(
		player.inventory.slots[ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1]["amount"],
		6)
		
	# now we cannot fit another 20 ore:
	assert_ne(
		player.inventory.fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			20,
			smelting_input_slots), 0)	
			
	# should be possible to fit 14 though
	assert_eq(
		player.inventory.fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			14,
			smelting_input_slots), 0)
			
	# we can remove some ore:
	player.inventory.remove_items(
		ItemDatabase.MaterialItemIds.COPPER_ORE,
		30,
		smelting_input_slots)
	
	# should be possible to fit 30 now
	assert_eq(
		player.inventory.fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			30,
			smelting_input_slots), 0)

class TestHitbox extends StaticBody2D:
	var id = 0
	
class TestServer extends Reference:
	var received_packets = []
	func send_packet(_id, data):
		received_packets.append(data["op_code"])
		
func test_smelting():
	var player : Player = Player.new()
	player.inventory.update({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT:
			{
				"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE,
				"amount" : 5
			}
	})
	
	var test_server = TestServer.new()
	player.hitbox = TestHitbox.new()
	player.server = test_server
	assert_true(player.attempt_to_start_smelter())
	assert_eq(player.inventory.smelter_started, true)
	
	# simulate timer timeout
	player.craft_smelting_recipe()
	
	var expected_packets = [
		ServerInterface.Opcodes.INVENTORY_SLOT_UPDATE,
		ServerInterface.Opcodes.INVENTORY_SLOT_UPDATE,
	]
	assert_eq(test_server.received_packets, expected_packets)
	test_server.received_packets = []
	
	# simulate another timer timeout
	player.craft_smelting_recipe()
	
	expected_packets = [
		ServerInterface.Opcodes.INVENTORY_SLOT_UPDATE,
		ServerInterface.Opcodes.INVENTORY_SLOT_UPDATE,
		ServerInterface.Opcodes.SMELTER_STOPPED
	]
	assert_eq(test_server.received_packets, expected_packets)
	test_server.received_packets = []
