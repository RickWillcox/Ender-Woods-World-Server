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
		"player_started_quests": {
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
		"player_started_quests": {
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
		"player_started_quests": {
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
		"player_started_quests": {
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
		"player_started_quests": {
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
	assert_true("1" in player_quests.get_player_quests()["player_started_quests"], "1 key is in Player Quests")
	var expected_updated_quest_state : Dictionary = {
		"player_started_quests": {

		},
		"all_quest_ids_completed": {
			"3": null
		}
	}
	player_quests.remove_player_started_quest_by_id("1")
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Delete a key using Quest ID")
	
func test_get_player_quests():
	var player_quests : Reference = test_set_player_quests_on_login()
	var expected_updated_quest_state : Dictionary = {
		"player_started_quests": {
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
		"player_started_quests": {
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

func test_get_player_started_and_completed_quests():
	var player_quests : Reference = test_set_player_quests_on_login()
	var quests_at_start : Dictionary = {
		"player_started_quests": {
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
	assert_true(player_quests.check_player_already_started_quest("1", player_quests.get_player_quests()["player_started_quests"]), "Player has started 1")	
	assert_false(player_quests.check_player_already_started_quest("2", player_quests.get_player_quests()["player_started_quests"]), "Player has not started 2")
	
	assert_true(player_quests.check_player_already_completed_quest("3", player_quests.get_player_quests()["all_quest_ids_completed"]), "Player has completed  3")
	assert_false(player_quests.check_player_already_completed_quest("1", player_quests.get_player_quests()["all_quest_ids_completed"]), "Player has not completed  1")
	assert_false(player_quests.check_player_already_completed_quest("4", player_quests.get_player_quests()["all_quest_ids_completed"]), "Player has not completed  4")
	
	#add started and completed quests and recheck
	var new_quests_started : Dictionary = {
		"player_started_quests": {
			"2": {
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
	player_quests.set_player_quests(player_quests.get_player_quests(), new_quests_started)
	assert_true(player_quests.check_player_already_started_quest("1", player_quests.get_player_quests()["player_started_quests"]), "Player has started 1")	
	assert_true(player_quests.check_player_already_started_quest("2", player_quests.get_player_quests()["player_started_quests"]), "Player has started 2")
	assert_false(player_quests.check_player_already_started_quest("3", player_quests.get_player_quests()["player_started_quests"]), "Player has not started 3")
	
	assert_true(player_quests.check_player_already_completed_quest("3", player_quests.get_player_quests()["all_quest_ids_completed"]), "Player has completed  3")
	assert_true(player_quests.check_player_already_completed_quest("4", player_quests.get_player_quests()["all_quest_ids_completed"]), "Player has completed  4")
	assert_false(player_quests.check_player_already_completed_quest("1", player_quests.get_player_quests()["all_quest_ids_completed"]), "Player has not completed  1")
	assert_false(player_quests.check_player_already_completed_quest("5", player_quests.get_player_quests()["all_quest_ids_completed"]), "Player has not completed  5")
	
	#remove a quest and recheck
	player_quests.remove_player_started_quest_by_id("1")
	assert_false(player_quests.check_player_already_started_quest("1", player_quests.get_player_quests()["player_started_quests"]), "Player has started 1")	
	assert_true(player_quests.check_player_already_started_quest("2", player_quests.get_player_quests()["player_started_quests"]), "Player has started 2")
	assert_false(player_quests.check_player_already_started_quest("3", player_quests.get_player_quests()["player_started_quests"]), "Player has not started 3")

func test_get_player_completed_quests_dictionary():
	var player_quests = PlayerQuests.new()
	assert_eq_deep({}, player_quests.get_player_completed_quests())
	assert_ne_deep({"Junk" : 1}, player_quests.get_player_completed_quests())
	var player_quest_state : Dictionary = {
		"player_started_quests": {
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
	assert_eq_deep({"4": null}, player_quests.get_player_completed_quests())
	assert_ne_deep({}, player_quests.get_player_completed_quests())
	
func test_get_player_started_quests_dictionary():
	var player_quests = PlayerQuests.new()
	assert_eq_deep({}, player_quests.get_player_started_quests())
	assert_ne_deep({"Junk" : 1}, player_quests.get_player_started_quests())
	var player_quest_state : Dictionary = {
		"player_started_quests": {
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
	assert_eq_deep({"3": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10
				}
			}}, player_quests.get_player_started_quests())
	assert_ne_deep({}, player_quests.get_player_started_quests())
