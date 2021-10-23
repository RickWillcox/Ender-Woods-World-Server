extends Node
class_name Player

var hitbox_scene = preload("res://Scenes/Player/PlayerHitbox.tscn")
var hitbox : StaticBody2D

func initialize(init_state):
	hitbox = hitbox_scene.instance()

func register(world):
  world.add_child(hitbox)

func update(new_state):
  hitbox.position = new_state[ServerData.PLAYER_POSITION]
  
func remove():
  hitbox.get_parent().remove_child(hitbox)
  hitbox.queue_free()
