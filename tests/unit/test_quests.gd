extends "res://addons/gut/test.gd"

func test_empty_player_quests():
	var player_quests := PlayerQuests.new()
	assert_eq({}.hash(), player_quests.quests.hash(), "Quest State Empty")
	
func test_set_player_quests_on_login():
	var player_quests := PlayerQuests.new()
	var initial_quests_on_login : Dictionary = {
		1 : {
			"kill_enemies" : {
				"slimes" : 3,
				"minos" : 2
			},
			"collect_items" : {
				"copper_sword" : 1
			}
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), initial_quests_on_login)
	assert_eq(player_quests.get_player_quests().hash(), initial_quests_on_login.hash(), "Quests should be equal")
	return player_quests
	
func test_update_player_quests_change_value():
	var player_quests : Reference = test_set_player_quests_on_login()
	var expected_updated_quest_state : Dictionary = {
		1 : {
			"kill_enemies" : {
				"slimes" : 2,
				"minos" : 2
			},
			"collect_items" : {
				"copper_sword" : 1
			}
		}
	}
	var updated_quest : Dictionary = {
		1 : {
			"kill_enemies" : {
				"slimes" : 2
			}
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), updated_quest)
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Checking Quest Update Values")


func test_update_player_quests_add_keys():
	var player_quests : Reference = test_set_player_quests_on_login()
	var expected_updated_quest_state : Dictionary = {
		1 : {
			"kill_enemies" : {
				"slimes" : 3,
				"minos" : 2,
				"deer" : 1
			},
			"collect_items" : {
				"copper_sword" : 1
			},
			"npcs" : {
				"name" : "bob"
			}
		},
		2 : {
			"kill_enemies" : {
				"boar" : 2,
			},
			"collect_items" : {
				"steel_sword" : 3
			},
			"npcs" : {
				"name" : "ross"
			}
		}
	}
	var updated_quest : Dictionary = {
		1 : {
			"kill_enemies" : {
				"deer" : 1
			},
			"npcs" : {
				"name" : "bob"
			}
		},
		2 : {
			"kill_enemies" : {
				"boar" : 2,
			},
			"collect_items" : {
				"steel_sword" : 3
			},
			"npcs" : {
				"name" : "ross"
			}
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), updated_quest)
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Checking Quest Update Keys")
	print(player_quests.get_player_quests())

func test_delete_quest_id_by_key():
	var player_quests : Reference = test_set_player_quests_on_login()
	assert_true(1 in player_quests.get_player_quests(), "1 key is in Player Quests")
	var expected_updated_quest_state : Dictionary = {}
	player_quests.del_player_quests(1)
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Delete a key using Quest ID")
	
func test_get_player_quests():
	var player_quests : Reference = test_set_player_quests_on_login()
	var expected_updated_quest_state : Dictionary = {
		1 : {
			"kill_enemies" : {
				"slimes" : 3,
				"minos" : 2
			},
			"collect_items" : {
				"copper_sword" : 1
			}
		}
	}
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Get Player Quests")

	
