extends "res://addons/gut/test.gd"

var all_quests : Dictionary = {
		  "1": {
			"quest_name": "I hate wet feet",
			"npc_begins": "fisherman_bob",
			"npc_ends" : "fisherman_bob",
			"requirements": {
				"min_level" : 0,
				"max_level" : 15,
				"previous_quests_completed" : {

				}
			},
			"items_given_at_beginning_of_quest": {

			},
			"item_rewards" : {

			},
			"other_rewards" : {

			},
			"unlocks_quest_ids" : {

			},
			"unlocks_new_skill" : {

			},
			"milestones" : {
				"kill_enemies" : {
					"mino" : 1
				},
				"collect_items" :{
					
				}
			}
		  },
			"2": {
				"quest_name": "Quest_2",
				"npc_begins": "fisherman_sam",
				"npc_ends" : "fisherman_sam",
				"requirements": {
					"min_level" : 1,
					"max_level" : 3,
					"previous_quests_completed" : {
						"0" : null,
						"1" : null
					}
				},
				"items_given_at_beginning_of_quest": {

				},
				"item_rewards" : {

				},
				"other_rewards" : {

				},
				"unlocks_quest_ids" : {

				},
				"unlocks_new_skill" : {

				},
				"milestones" : {
					"kill_enemies" : {
						"mino" : 1
					},
					"collect_items" :{
						
					}
				}
			  },
			"3": {
			"quest_name": "Quest_3",
			"npc_begins": "fisherman_bob",
			"npc_ends" : "fisherman_bob",
			"requirements": {
				"min_level" : 0,
				"max_level" : 15,
				"previous_quests_completed" : {

				}
			},
			"items_given_at_beginning_of_quest": {

			},
			"item_rewards" : {

			},
			"other_rewards" : {

			},
			"unlocks_quest_ids" : {

			},
			"unlocks_new_skill" : {

			},
			"milestones" : {
				"kill_enemies" : {
					"mino" : 1
				},
				"collect_items" :{
					
				}
			}
		  }
		  
		}

func test_empty_player_quests():
	var player_quests := PlayerQuests.new()
	assert_eq({}.hash(), player_quests.quests.hash(), "Quest State Empty")
	
func test_set_player_quests_on_login():
	var player_quests := PlayerQuests.new()
	var initial_quests_on_login : Dictionary = {
		"active_quests_tracking": {
			"1": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10
				}
			}
		},
		"all_quest_ids_completed": {
			"3": null
		}
	}
	
	player_quests.set_player_quests(player_quests.get_player_quests(), initial_quests_on_login)
	assert_eq(player_quests.get_player_quests().hash(), initial_quests_on_login.hash(), "Quests should be equal")
	return player_quests
	
func test_update_player_quests_change_value():
	var player_quests : Reference = test_set_player_quests_on_login()
	var expected_updated_quest_state : Dictionary = {
		"active_quests_tracking": {
			"1": {
				"kill_enemies": {
					"slimes": 2,
					"minos" : 10
				}
			}
		},
		"all_quest_ids_completed": {
			"3": null
		}
	}
	var updated_quest : Dictionary = {
		"active_quests_tracking": {
			"1": {
				"kill_enemies": {
					"slimes": 2,
					"minos" : 10
				}
			}
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), updated_quest)
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Checking Quest Update Values")

func test_update_player_quests_add_keys():
	var player_quests : Reference = test_set_player_quests_on_login()
	var expected_updated_quest_state : Dictionary = {
		"active_quests_tracking": {
			"1": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10,
					"deers" : 10
				}
			}
		},
		"all_quest_ids_completed": {
			"3": null,
			"4": null		
		}
	}
	var updated_quest : Dictionary = {
		"active_quests_tracking": {
			"1": {
				"kill_enemies": {
					"deers" : 10
				}
			}
		},
		"all_quest_ids_completed": {
			"4": null
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), updated_quest)
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Checking Quest Update Keys")
	print(player_quests.get_player_quests())

func test_delete_quest_id_by_key():
	var player_quests : Reference = test_set_player_quests_on_login()
	assert_true("1" in player_quests.get_player_quests()["active_quests_tracking"], "1 key is in Player Quests")
	var expected_updated_quest_state : Dictionary = {
		"active_quests_tracking": {

		},
		"all_quest_ids_completed": {
			"3": null
		}
	}
	player_quests.del_player_quests("1")
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Delete a key using Quest ID")
	
func test_get_player_quests():
	var player_quests : Reference = test_set_player_quests_on_login()
	var expected_updated_quest_state : Dictionary = {
		"active_quests_tracking": {
			"1": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10
				}
			}
		},
		"all_quest_ids_completed": {
			"3": null
		}
	}
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Get Player Quests")

func test_check_requirements():
	var player_stats : Dictionary = {
		"level" : 0
	}
	var player_quests : PlayerQuests = PlayerQuests.new()
	var player_quest_state : Dictionary = {
		"active_quests_tracking": {
			"3": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10
				}
			}
		},
		"all_quest_ids_completed": {
			"4": null
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), player_quest_state)
	var quests_available_to_begin : Dictionary = player_quests.check_all_quest_requirements_to_start(player_stats, all_quests)
	assert_true(quests_available_to_begin.has("1"), "Quest can be started")
	assert_false(quests_available_to_begin.has("2"), "Quest cannot be started because havent completed previous quests")
	assert_false(quests_available_to_begin.has("3"), "Quest cannot be started because the player has already started that quest")
	assert_false(quests_available_to_begin.has("999"), "Quest does not exist")
