extends "res://addons/gut/test.gd"

var all_quests : Dictionary = {
  "1": {
	"story": "Player wakes up naked on the beach, after being washed ashore. Fisherman Bob nearby offers you some help and tells you to talk to his village chief and also give him this bucket of fish as he might be able to provide you further assistance. When you talk to Beach Chief Sam he sees you are hurt and offers you some Health Potions to heal. He also takes the fish.",
	"npc_ends": "beach_chief_sam",
	"milestones": {},
	"npc_starts": "fisherman_bob",
	"quest_name": "I hate wet feet",
	"item_rewards": {
	  "REPLACE_minor_health_potion_ITEM_ID": {
		"quantity": 3,
		"item_name": "Minor Potion of Health"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {}
	},
	"other_rewards": {},
	"items_given_at_beginning_of_quest": {
	  "REPLACE_bucket_of_fish_ITEM_ID": {
		"quantity": 1,
		"item_name": "Bucket of Fish"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "REPLACE_bucket_of_fish_ITEM_ID": {
		"quantity": 1,
		"item_name": "Bucket of Fish"
	  }
	}
  },
  "2": {
	"story": "Player talks to Beach Chief Sam, Sam says all are welcome here as long as they put in their fair share of work.He tells you how he is craving some beautiful crab soup but the hunters have gone missing for weeks now and there is no one here to hunt the crabs anymore. How about you take this copper sword and go get the crab guts for me and I will return the favour by giving you some coin to get you started on your travels.",
	"npc_ends": "beach_chief_sam",
	"milestones": {},
	"npc_starts": "beach_chief_sam",
	"quest_name": "Crab soup",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 10,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {
	  "6": {
		"quantity": 1,
		"item_name": "Copper Sword"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "REPLACE_CRAB_GUTS_ITEM_ID": {
		"quantity": 10,
		"item_name": "Crab Guts"
	  }
	}
  },
  "3": {
	"story": "Player gets told to go look for those damn miners. They haven't been back in days, things are not like they used to be around here. Player then follows the beach track over to the Miners who have a camp set up.",
	"npc_ends": "miner_greg",
	"milestones": {},
	"npc_starts": "beach_chief_sam",
	"quest_name": "Where are those damn miners?",
	"item_rewards": {},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"2": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {
	  "REPLACE_NOTE_FOR_MINER_GREG": {
		"quantity": 1,
		"item_name": "Note for Miner Greg"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "REPLACE_NOTE_FOR_MINER_GREG": {
		"quantity": 1,
		"item_name": "Note for Miner Greg"
	  }
	}
  },
  "4": {
	"story": "Miner Greg after having read the note from Beach Chief Sam whines about how he has no idea how things work these days, “we've only been gone for a few days, cant the old bastard look after himself for a few days?”. Anyways kid, since you’re new here you are going to need some gear. I tell you what, Ill give you this copper pickaxe if you'll go get me 10 copper ore from those rocks over there. If you can do that ill give you a nice pair of boots that’ll protect ya feet from the hot sand. ",
	"npc_ends": "miner_greg",
	"milestones": {},
	"npc_starts": "miner_greg",
	"quest_name": "Go hit some rocks kid!",
	"item_rewards": {
	  "5": {
		"quantity": 1,
		"item_name": "Copper Boots"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null
	  }
	},
	"other_rewards": {
	  "mining_experience": 100
	},
	"items_given_at_beginning_of_quest": {
	  "10": {
		"quantity": 1,
		"item_name": "Copper Pickaxe"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "100000": {
		"quantity": 10,
		"item_name": "Copper Ore"
	  }
	}
  },
  "5": {
	"story": "Miner Greg tells you that unless you want to end up like the cranky old man (referring to Beach Chief Sam), I'd get the hell off the beach whilst you can. He says he doesn't know much about the rest of the world but his friend Travelling Vendor Robby hangs out around the crossroads selling  various goods and that you should ask him where to go next. Or do whatever you want, what do I care? The player then upon leaving the beach sees an obvious crossroads ahead where he finds Travelling Vendor Robby. Robby then offers you some items from his shop, but you can only afford to buy 1 small cooked fish. Robby scoffs at your poverty and tosses a single silver coin at your feet in disgust. ",
	"npc_ends": "travelling_vendor_robby",
	"milestones": {},
	"npc_starts": "miner_greg",
	"quest_name": "These boots were made for walkin",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 1,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null,
		"4": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "6": {
	"story": "Why are you even hanging around me? Be gone. Bloody peasants wasting my time, you bloody young people and your work ethic, go get yourself a job from the Recruiter Billy in town and get your act together! Player … Player then goes to town and finds Recruiter Billy standing next to the Job Board, Billy tells you there is always work to be done and you can always find work on this Job Board. Player What do you do then? Billy: ...",
	"npc_ends": "recruiter_billy",
	"milestones": {},
	"npc_starts": "travelling_vendor_robby",
	"quest_name": "Time to make something of myself…. I guess",
	"item_rewards": {},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null,
		"4": null,
		"5": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "7": {
	"story": "First Job Board quest and last in the first quest chain. Introduces the player to the job board. Kill 15 deer.",
	"npc_ends": "ender_town_job_board",
	"milestones": {
	  "enemies_left_to_kill": {
		"deer": 15
	  }
	},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Deers gotta go",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 5,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null,
		"4": null,
		"5": null,
		"6": null
	  }
	},
	"other_rewards": {
	  "player_experience": 200
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "1001": {
	"story": "Job Board repeatable quest: Kill 15 boars",
	"npc_ends": "ender_town_job_board",
	"milestones": {
	  "enemies_left_to_kill": {
		"boar": 15
	  }
	},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Hunt some Boars",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 5,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": true,
	  "previous_quests_completed": {
		"7": null
	  }
	},
	"other_rewards": {
	  "player_experience": 200
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "1002": {
	"story": "Job Board repeatable quest: Kill 20 slimes",
	"npc_ends": "ender_town_job_board",
	"milestones": {
	  "enemies_left_to_kill": {
		"slime": 20
	  }
	},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Squishy Slimes",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 10,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": true,
	  "previous_quests_completed": {
		"7": null
	  }
	},
	"other_rewards": {
	  "player_experience": 200
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "1003": {
	"story": "Job Board repeatable quest: Trade in 20 Boar Meat",
	"npc_ends": "ender_town_job_board",
	"milestones": {},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Pig on a spit",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 40,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": true,
	  "previous_quests_completed": {
		"7": null
	  }
	},
	"other_rewards": {
	  "player_experience": 800
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {
	  "REPLACE_BOAR_MEAT_ITEM_ID": {
		"quantity": 20,
		"item_name": "Boar Meat"
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
		"player_completed_quest_ids": {
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
		"player_completed_quest_ids": {
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
		"player_completed_quest_ids": {
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
		"player_completed_quest_ids": {
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
		"player_completed_quest_ids": {
			"3": null
		}
	}
	player_quests.remove_player_started_quest_by_id("1")
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "Delete a key using Quest ID")
	
	# testing trying to remove a quest id that doenst exist in player_quests
	player_quests.remove_player_started_quest_by_id("1")
	assert_eq(player_quests.get_player_quests().hash(), expected_updated_quest_state.hash(), "No Error and no change")
	
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
		"player_completed_quest_ids": {
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
		"player_completed_quest_ids": {
			"4": null
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), player_quest_state)
	var quests_available_to_start : Dictionary = player_quests.check_all_quest_requirements_to_start(player_stats, player_quests.get_player_quests(), all_quests)
	assert_true(quests_available_to_start.has("1"), "Quest can be started")
	assert_false(quests_available_to_start.has("2"), "Quest cannot be started because havent completed previous quests")
	assert_false(quests_available_to_start.has("3"), "Quest cannot be started because the player has already started that quest")
	assert_false(quests_available_to_start.has("999"), "Quest does not exist")

	# testing different scenario
	player_quests = PlayerQuests.new()
	player_quest_state = {
		"player_started_quests": {},
		"player_completed_quest_ids": {}
	}
	var updated_player_quest_state : Dictionary = {
		"player_started_quests": {
			"1" : {
				
			}
		},
		"player_completed_quest_ids": {}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), player_quest_state)
	quests_available_to_start = player_quests.check_all_quest_requirements_to_start(player_stats, player_quests.get_player_quests(), all_quests)
	assert_true(quests_available_to_start.has("1"), "Quest can be started")
	assert_false(quests_available_to_start.has("2"), "Quest cannot be started because havent completed previous quests")	
	player_quests.set_player_quests(player_quests.get_player_quests(), updated_player_quest_state)
	assert_true(player_quests.set_quest_to_completed("1"), "1 was set to completed")
	quests_available_to_start = player_quests.check_all_quest_requirements_to_start(player_stats, player_quests.get_player_quests(), all_quests)
	assert_false(quests_available_to_start.has("1"), "Quest cannot be started as it is completed")
	assert_true(quests_available_to_start.has("2"), "Quest can be started")	
	assert_false(quests_available_to_start.has("3"), "Quest cannot be started as player has not met requirements")
	
	updated_player_quest_state = {
		"player_started_quests": {
			"2" : {			
			}
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), updated_player_quest_state)
	assert_false(player_quests.set_quest_to_completed("3"), "3 cannot be set to completed")
	assert_true(player_quests.set_quest_to_completed("2"), "2 was set to completed")
	quests_available_to_start = player_quests.check_all_quest_requirements_to_start(player_stats, player_quests.get_player_quests(), all_quests)
	assert_false(quests_available_to_start.has("1"), "1 Quest cannot be started as it is completed")
	assert_false(quests_available_to_start.has("2"), "2 Quest cannot be started as it is completed")
	assert_true(quests_available_to_start.has("3"), "3 Quest can be started")
	assert_false(quests_available_to_start.has("4"), "4 Quest cannot be started as requirements are not met")
	
	

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
		"player_completed_quest_ids": {
			"3": null
		}
	}
	assert_true(player_quests.check_player_already_started_quest("1", player_quests.get_player_quests()["player_started_quests"]), "Player has started 1")	
	assert_false(player_quests.check_player_already_started_quest("2", player_quests.get_player_quests()["player_started_quests"]), "Player has not started 2")
	
	assert_true(player_quests.check_player_already_completed_quest("3", player_quests.get_player_quests()["player_completed_quest_ids"]), "Player has completed  3")
	assert_false(player_quests.check_player_already_completed_quest("1", player_quests.get_player_quests()["player_completed_quest_ids"]), "Player has not completed  1")
	assert_false(player_quests.check_player_already_completed_quest("4", player_quests.get_player_quests()["player_completed_quest_ids"]), "Player has not completed  4")
	
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
		"player_completed_quest_ids": {
			"4": null
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), new_quests_started)
	assert_true(player_quests.check_player_already_started_quest("1", player_quests.get_player_quests()["player_started_quests"]), "Player has started 1")	
	assert_true(player_quests.check_player_already_started_quest("2", player_quests.get_player_quests()["player_started_quests"]), "Player has started 2")
	assert_false(player_quests.check_player_already_started_quest("3", player_quests.get_player_quests()["player_started_quests"]), "Player has not started 3")
	
	assert_true(player_quests.check_player_already_completed_quest("3", player_quests.get_player_quests()["player_completed_quest_ids"]), "Player has completed  3")
	assert_true(player_quests.check_player_already_completed_quest("4", player_quests.get_player_quests()["player_completed_quest_ids"]), "Player has completed  4")
	assert_false(player_quests.check_player_already_completed_quest("1", player_quests.get_player_quests()["player_completed_quest_ids"]), "Player has not completed  1")
	assert_false(player_quests.check_player_already_completed_quest("5", player_quests.get_player_quests()["player_completed_quest_ids"]), "Player has not completed  5")
	
	#remove a quest and recheck
	player_quests.remove_player_started_quest_by_id("1")
	assert_false(player_quests.check_player_already_started_quest("1", player_quests.get_player_quests()["player_started_quests"]), "Player has started 1")	
	assert_true(player_quests.check_player_already_started_quest("2", player_quests.get_player_quests()["player_started_quests"]), "Player has started 2")
	assert_false(player_quests.check_player_already_started_quest("3", player_quests.get_player_quests()["player_started_quests"]), "Player has not started 3")

func test_get_player_completed_quests_dictionary():
	var player_quests = PlayerQuests.new()
	assert_eq_deep({}, player_quests.get_player_completed_quests(player_quests.get_player_quests()))
	assert_ne_deep({"Junk" : 1}, player_quests.get_player_completed_quests(player_quests.get_player_quests()))
	var player_quest_state : Dictionary = {
		"player_started_quests": {
			"3": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10
				}
			}
		},
		"player_completed_quest_ids": {
			"4": null
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), player_quest_state)
	assert_eq_deep({"4": null}, player_quests.get_player_completed_quests(player_quests.get_player_quests()))
	assert_ne_deep({}, player_quests.get_player_completed_quests(player_quests.get_player_quests()))
	
func test_get_player_started_quests_dictionary():
	var player_quests = PlayerQuests.new()
	assert_eq_deep({}, player_quests.get_player_started_quests(player_quests.get_player_quests()))
	assert_ne_deep({"Junk" : 1}, player_quests.get_player_started_quests(player_quests.get_player_quests()))
	var player_quest_state : Dictionary = {
		"player_started_quests": {
			"3": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10
				}
			}
		},
		"player_completed_quest_ids": {
			"4": null
		}
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), player_quest_state)
	assert_eq_deep({"3": {
				"kill_enemies": {
					"slimes": 20,
					"minos" : 10
				}
			}}, player_quests.get_player_started_quests(player_quests.get_player_quests()))
	assert_ne_deep({}, player_quests.get_player_started_quests(player_quests.get_player_quests()))

func test_set_quest_to_completed():
	var player_quests = PlayerQuests.new()
	var add_quest : Dictionary = {
		"player_started_quests" : {
			"1" : {
				"kill_enemies" : {
					"slimes" : 10
				}
			}
		},
		"player_completed_quest_ids" : {
			
		}	
	}
	player_quests.set_player_quests(player_quests.get_player_quests(), add_quest)
	assert_eq_deep(add_quest, player_quests.get_player_quests())
	print(player_quests.get_player_quests())
	
	var after_quest_completed : Dictionary = {
		"player_completed_quest_ids" : {
			"1" : null
		}
	}
	#some of these checks are kinda overkill as they are run in set quests to complete
	assert_true(player_quests.set_quest_to_completed("1"), "1 is removed from started and moved to completed")
	assert_false(player_quests.check_player_already_started_quest("1", player_quests.get_player_started_quests(player_quests.get_player_quests())))
	assert_true(player_quests.check_player_already_completed_quest("1", player_quests.get_player_completed_quests(player_quests.get_player_quests())))
	assert_false(player_quests.set_quest_to_completed("3"), "3 not in started quests so cant complete it")


	
	
