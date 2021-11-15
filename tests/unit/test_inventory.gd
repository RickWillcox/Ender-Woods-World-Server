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
	ItemDatabase.all_item_data = { item_id : {"item_category" : ItemDatabase.Category.BODY_ARMOR} }
	
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


func test_has_materials():
	var material_item_id = 3
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT
	var inventory = Inventory.new()
	inventory.add_item_to_empty_slot(material_item_id, 4, slot)
	assert_true(inventory.has_materials({material_item_id : 4}))
	assert_false(inventory.has_materials({material_item_id : 5}))


func test_has_materials_many_slots():
	var material_item_id = 3
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT
	var inventory = Inventory.new()
	inventory.add_item_to_empty_slot(material_item_id, 1, slot)
	inventory.add_item_to_empty_slot(material_item_id, 3, slot + 1)
	assert_true(inventory.has_materials({material_item_id : 4}))
	assert_false(inventory.has_materials({material_item_id : 5}))

func test_remove_materials_many_slots():
	var material_item_id = 3
	var slot = ItemDatabase.Slots.FIRST_BACKPACK_SLOT
	var inventory = Inventory.new()
	inventory.add_item_to_empty_slot(material_item_id, 1, slot)
	inventory.add_item_to_empty_slot(material_item_id, 3, slot + 1)
	inventory.add_item_to_empty_slot(material_item_id, 3, slot + 2)
	
	inventory.remove_materials({material_item_id : 7})
	
	# all slots are emptied
	assert_false(inventory.slots.has(slot))
	assert_false(inventory.slots.has(slot + 1))
	assert_false(inventory.slots.has(slot + 2))

func test_last_empty_slot():
	var material_item_id = ItemDatabase.MaterialItemIds.COPPER_ORE
	var inventory : Inventory = Inventory.new()
	for _i in range(25):
		var slot = inventory.find_empty_slot()
		assert_true(inventory.add_item_to_empty_slot(material_item_id, 1, slot))
		
	assert_eq(inventory.find_empty_slot(), -1)

func test_ore_fits_smelter_input():
	var ores = [ItemDatabase.MaterialItemIds.COPPER_ORE,
				ItemDatabase.MaterialItemIds.TIN_ORE,
				ItemDatabase.MaterialItemIds.IRON_ORE,
				ItemDatabase.MaterialItemIds.SILVER_ORE,
				ItemDatabase.MaterialItemIds.GOLD_ORE]
	ItemDatabase.all_item_data = {}
	for ore in ores:
		ItemDatabase.all_item_data[ore] = { "item_category" : ItemDatabase.Category.ORE}
	
	for ore in ores:
		for slot in range(ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT, ItemDatabase.Slots.LAST_SMELTING_INPUT_SLOT + 1):
			assert_true(ItemDatabase.item_fits_slot(ore, slot))
		for slot in range(ItemDatabase.Slots.FIRST_SMELTING_OUTPUT_SLOT, ItemDatabase.Slots.LAST_SMELTING_OUTPUT_SLOT + 1):
			assert_false(ItemDatabase.item_fits_slot(ore, slot))

func test_coal_fits_smelter_coal_slot():
	var coal_id = ItemDatabase.MaterialItemIds.COAL
	var coal_slot = ItemDatabase.Slots.COAL_SMELTING_INPUT_SLOT
	assert_true(ItemDatabase.item_fits_slot(coal_id, coal_slot))

func test_metal_bars_fit_smelter_output():
	var metal_bars = [ItemDatabase.MaterialItemIds.COPPER_BAR,
						ItemDatabase.MaterialItemIds.BRONZE_BAR,
						ItemDatabase.MaterialItemIds.IRON_BAR,
						ItemDatabase.MaterialItemIds.SILVER_BAR,
						ItemDatabase.MaterialItemIds.GOLD_BAR]
	ItemDatabase.all_item_data = {}
	for metal_bar in metal_bars:
		ItemDatabase.all_item_data[metal_bar] = { "item_category" : ItemDatabase.Category.METAL_BAR}
	
	for metal_bar in metal_bars:
		for slot in range(ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT, ItemDatabase.Slots.LAST_SMELTING_INPUT_SLOT + 1):
			assert_false(ItemDatabase.item_fits_slot(metal_bar, slot))
		for slot in range(ItemDatabase.Slots.FIRST_SMELTING_OUTPUT_SLOT, ItemDatabase.Slots.LAST_SMELTING_OUTPUT_SLOT + 1):
			assert_true(ItemDatabase.item_fits_slot(metal_bar, slot))
