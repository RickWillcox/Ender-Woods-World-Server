extends "res://addons/gut/test.gd"

func test_player_new():
	var _player = Player.new()
	assert_true(true)
	
func test_player_inventory():
	var player = Player.new()
	player.set_inventory({17 : {"item_id" : 3, "amount" : 3}} )
	assert_true(player.get_item(17) == 3)

func test_player_can_craft():
	ItemDatabase.all_recipe_data[0] = { "materials" : {3 : 2}}
	var player = Player.new()
	player.set_inventory({17 : {"item_id" : 3, "amount" : 3}} )
	assert_true(player.can_craft_recipe(0))

func test_player_craft():
	var result_item_id = 5
	ItemDatabase.all_recipe_data[0] = { "materials" : {3 : 2, 4: 10},
										"result_item_id" : result_item_id}
	var player = Player.new()
	player.set_inventory(
		{17 : {"item_id" : 3, "amount" : 1},
		18 : {"item_id" : 4, "amount" : 1},
		30 : {"item_id" : 3, "amount" : 2},
		31 : {"item_id" : 4, "amount" : 9}})
	assert_true(player.can_craft_recipe(0))
	player.craft_recipe(0)
	
	# Check that player has exactly 1 item from recipe
	assert_true(player.inventory.has_items(result_item_id))
	player.inventory.remove_items(result_item_id)
	assert_false(player.inventory.has_items(result_item_id))
	
	# check that corrent number of matetials was removed
	assert_false(player.inventory.has_items(4))
	assert_true(player.inventory.has_items(3))
	player.inventory.remove_items(3)
	assert_false(player.inventory.has_items(3))


func test_player_find_recipe_for_smelter():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 3 }
	})
	ItemDatabase.all_recipe_data[0] = {
		"materials": { ItemDatabase.MaterialItemIds.COPPER_ORE: 2 }
	}
	assert_eq(player.find_recipe_for_smelter(), 0)
	

func test_player_find_recipe_for_smelter_no_items():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 1 }
	})
	ItemDatabase.all_recipe_data[0] = {
		"materials": { ItemDatabase.MaterialItemIds.COPPER_ORE: 2 }
	}
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
	ItemDatabase.all_recipe_data[0] = {
		"materials": {
			ItemDatabase.MaterialItemIds.COPPER_ORE: 2,
			ItemDatabase.MaterialItemIds.TIN_ORE : 1
		 }
	}
	assert_eq(player.find_recipe_for_smelter(), 0)
	

func test_player_find_recipe_for_smelter_complex_no_items():
	var player = Player.new()
	player.set_inventory({
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT: {
			"item_id" : ItemDatabase.MaterialItemIds.COPPER_ORE, "amount" : 3
		},
		ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1: {
			"item_id" : ItemDatabase.MaterialItemIds.TIN_ORE, "amount" : 1
		}
	})
	ItemDatabase.all_recipe_data[0] = {
		"materials": {
			ItemDatabase.MaterialItemIds.COPPER_ORE: 2,
			ItemDatabase.MaterialItemIds.TIN_ORE : 2
		 }
	}
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
	ItemDatabase.all_recipe_data[0] = {
		"materials": {
			ItemDatabase.MaterialItemIds.COPPER_ORE: 4,
		 }
	}
	assert_eq(player.find_recipe_for_smelter(), 0)


func test_player_add_remove_smelter_items():
	var player = Player.new()
	ItemDatabase.all_item_data[ItemDatabase.MaterialItemIds.COPPER_ORE] = {
		"stack_size" : 20,
		"item_category" : ItemDatabase.Category.ORE
	}
	
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
			
	player.inventory.add_item2(ItemDatabase.MaterialItemIds.COPPER_ORE, 2, smelting_input_slots)
	
	# always adds to the first slot unless its full
	assert_eq(
		player.inventory.slots[ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT]["amount"],
		5)
		
	# We can fit another 20 ore:
	assert_true(
		player.inventory.can_fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			20,
			smelting_input_slots))
		
	# add 20 ore
	player.inventory.add_item2(ItemDatabase.MaterialItemIds.COPPER_ORE, 20, smelting_input_slots)
		
	# first slot has 20 now
	assert_eq(
		player.inventory.slots[ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT]["amount"],
		20)
	
	# second slot has 5 + 1
	assert_eq(
		player.inventory.slots[ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1]["amount"],
		6)
		
	# now we cannot fit another 20 ore:
	assert_false(
		player.inventory.can_fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			20,
			smelting_input_slots))	
			
	# should be possible to fit 14 though
	assert_true(
		player.inventory.can_fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			14,
			smelting_input_slots))
			
	# we can remove some ore:
	player.inventory.remove_items(
		ItemDatabase.MaterialItemIds.COPPER_ORE,
		30,
		smelting_input_slots)
	
	# should be possible to fit 30 now
	assert_true(
		player.inventory.can_fit_item(
			ItemDatabase.MaterialItemIds.COPPER_ORE,
			30,
			smelting_input_slots))
