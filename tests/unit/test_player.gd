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
