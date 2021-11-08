extends StaticBody2D

onready var gameserver = get_node("/root/Server")
var item_id : int
var tagged_by_player : int
var anyone_pick_up : bool = true
#move to common submodule eventually
var pick_up_range : int = 100

func _ready():
	name = str(randi () % 10000000+1)
	gameserver.add_item_drop_to_client(item_id, name, position, tagged_by_player)

func _on_RemoveItem_timeout():
	#Remove the item from the world server
	gameserver.remove_item_drop_from_client(name)
	queue_free()


func _on_PickupPlayer_timeout():
	#Allow other players to pick up the item
	anyone_pick_up = true
	

func player_in_range_of_item(player_id) -> bool:
	if get_node("/root/Server/ServerMap/YSort/Players/%d" % [player_id]).position.distance_to(position) < pick_up_range:
		return true
	return false


