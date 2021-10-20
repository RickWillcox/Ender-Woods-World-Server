extends Node2D


var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn") #change to mino
var melee_attack = preload("res://Scenes/Player/Melee_Attack.tscn")

# warning-ignore:unused_argument

func SpawnEnemy(enemy_id, location, type):
	var enemy_spawn
	if type == "Slime":
		enemy_spawn = slime
	elif type == "Mino":
		enemy_spawn = mino	
	var enemy_spawn_instance = enemy_spawn.instance()
	enemy_spawn_instance.name = str(enemy_id)
	enemy_spawn_instance.position = location
	get_node("YSort/Enemies/").add_child(enemy_spawn_instance, true)
	
func SpawnMelee(player_id, blend_position, player_position):
	var melee_attack_instance = melee_attack.instance()
	melee_attack_instance.player_id = player_id
	melee_attack_instance.position = player_position
	melee_attack_instance.change_rotation(blend_position)
	get_node("PlayerAttacks").add_child(melee_attack_instance)
	
func SpawnOre(ore_id, location):
	print("ore spawned")
	
func SpawnPlayer(player_id, _location):
	pass
	
	

