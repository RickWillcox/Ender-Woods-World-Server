extends Node

var all_quests : Dictionary = {}

func set_all_quests(quest_data_from_database):
	all_quests = quest_data_from_database

func get_all_quests():
	return all_quests
