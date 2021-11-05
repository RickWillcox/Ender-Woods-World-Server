extends StaticBody2D

onready var gameserver = get_node("/root/Server")
var item_id : int
var tagged_by_player : int
var anyone_pick_up : bool = true

func _ready():
	name = str(randi () % 10000000+1)
	gameserver.AddItemDropToClient(item_id, name, position, tagged_by_player)
	print(name)

func _on_RemoveItem_timeout():
	#Remove the item from the world server
	print("Removing item")
	gameserver.RemoveItemDropFromClient(name)
	queue_free()
	pass


func _on_PickupPlayer_timeout():
	#Allow other players to pick up the item
	print("Item available for anyone to pick up")
	anyone_pick_up = true
