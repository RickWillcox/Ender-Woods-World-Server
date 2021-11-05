extends StaticBody2D

onready var gameserver = get_node("/root/Server")
var item_id : int
var player_id : int
var anyone_pick_up : bool = true

func _ready():
	$PickupPlayer.start()
	$RemoveItem.start()
	gameserver.AddItemDropToClient(item_id, name, position)


func _on_RemoveItem_timeout():
	#Remove the item from the world server
	print("Removing item")
	queue_free()
	pass


func _on_PickupPlayer_timeout():
	#Allow other players to pick up the item
	print("Item available for anyone to pick up")
	anyone_pick_up = true
