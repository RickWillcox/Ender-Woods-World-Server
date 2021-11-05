extends Node2D


var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn") #change to mino
var melee_attack = preload("res://Scenes/Player/Melee_Attack.tscn")
var item_drop = preload("res://Scenes/Props/ItemGround.tscn")

# warning-ignore:unused_argument

func SpawnEnemy(enemy_id, location, type, status_dict):
	var enemy_spawn
	if type == "Slime":
		enemy_spawn = slime
	elif type == "Mino":
		enemy_spawn = mino	
	var enemy_spawn_instance = enemy_spawn.instance()
	enemy_spawn_instance.name = str(enemy_id)
	enemy_spawn_instance.position = location
	enemy_spawn_instance.set_status_dict(status_dict)
	get_node("YSort/Enemies/").add_child(enemy_spawn_instance, true)
	
func SpawnMelee(player_id, blend_position, player_position):
	var melee_attack_instance = melee_attack.instance()
	melee_attack_instance.player_id = player_id
	melee_attack_instance.position = player_position
	melee_attack_instance.change_rotation(blend_position)
	get_node("PlayerAttacks").add_child(melee_attack_instance)
	print(GetItemsOnGround())
	
func SpawnOre(_ore_id, _location : Vector2):
	Logger.info("%s: ore spawned %d, location=[%f,%f]" % [filename, _ore_id, _location.x, _location.y])
	
func SpawnPlayer(_player_id, _location):
	pass
	
	
func SpawnItemDrop(drop_position, item_id):
	var new_item_drop = item_drop.instance()
	new_item_drop.position = drop_position
	new_item_drop.item_id = item_id
	get_node("YSort/Items").add_child(new_item_drop)
	
func GetItemsOnGround() -> Array:
#	var item_nodes : Array = get_node("YSort/Items").get_children()
	var item_node_names : Array
	for item in get_node("YSort/Items").get_children():
		item_node_names.append([item.item_id, item.name, item.position])	
	return item_node_names
	
	
	
		
	
