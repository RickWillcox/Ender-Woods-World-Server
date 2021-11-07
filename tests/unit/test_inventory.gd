extends "res://addons/gut/test.gd"

func test_move_item_empty_slot_backpack():
	var inventory = Inventory.new()
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 1
	var to_slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 2
	var item_id = 3
	inventory.update({ slot: {"item_id": item_id, "amount": 1}})
	assert_true(inventory.move_items(slot, to_slot, false))
	assert_eq(inventory.slots[to_slot]["item_id"], item_id)
	assert_does_not_have(inventory.slots, slot)
	
func test_move_item_empty_slot_backpack_reversible():
	var inventory = Inventory.new()
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 1
	var to_slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 2
	var item_id = 3
	inventory.update({ slot: {"item_id": item_id, "amount": 1}})
	var inventory_copy = inventory.slots.duplicate(true)
	assert_true(inventory.move_items(slot, to_slot))
	assert_eq(inventory.slots[to_slot]["item_id"], item_id)
	assert_does_not_have(inventory.slots, slot)
	
	inventory.reverse_last_operation()
	# inventory returns to previous state
	assert_eq_deep(inventory.slots, inventory_copy)

func test_move_items_backpack():
	var inventory = Inventory.new()
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 1
	var to_slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 2
	var item_id = 3
	var to_item_id = 5
	inventory.update({ slot: {"item_id": item_id, "amount": 1},
					to_slot: {"item_id": to_item_id, "amount" : 1} })
	assert_true(inventory.move_items(slot, to_slot, false))
	assert_eq(inventory.slots[to_slot]["item_id"], item_id)
	assert_eq(inventory.slots[slot]["item_id"], to_item_id)
	
	
func test_move_items_backpack_reversible():
	var inventory = Inventory.new()
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 1
	var to_slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT + 2
	var item_id = 3
	var to_item_id = 5
	inventory.update({ slot: {"item_id": item_id, "amount": 1},
					to_slot: {"item_id": to_item_id, "amount" : 1} })
	var inventory_copy = inventory.slots.duplicate(true)
	assert_true(inventory.move_items(slot, to_slot))
	assert_eq(inventory.slots[to_slot]["item_id"], item_id)
	assert_eq(inventory.slots[slot]["item_id"], to_item_id)
	
	inventory.reverse_last_operation()
	assert_eq_deep(inventory.slots, inventory_copy)	

func test_is_move_to_slot_allowed():
	var item_id = 3
	ItemDatabase.all_item_data = { item_id : {"item_category" : ItemDatabase.CHEST} }
	
	var inventory = Inventory.new()
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT
	inventory.update({ slot: {"item_id": item_id, "amount": 1}})
	assert_true(inventory.is_move_to_slot_allowed(slot, ItemDatabase.Slots.CHEST_SLOT))
	assert_false(inventory.is_move_to_slot_allowed(slot, ItemDatabase.Slots.MAIN_HAND_SLOT))

func test_add_item_to_empty_slot():
	var item_id = 3
	var inventory = Inventory.new()
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT
	assert_true(inventory.add_item_to_empty_slot(item_id, 1, slot))
	assert_false(inventory.add_item_to_empty_slot(item_id, 1, slot))
	slot += 1
	assert_true(inventory.add_item_to_empty_slot(item_id, 1, slot))
	assert_false(inventory.add_item_to_empty_slot(item_id, 1, ItemDatabase.Slots.CHEST_SLOT))
