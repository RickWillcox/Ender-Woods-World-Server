extends Node
class_name Player

var hitbox_scene = preload("res://Scenes/Player/PlayerHitbox.tscn")
var hitbox : StaticBody2D
var si = ServerInterface

var stats = {}

func initialize(init_state):
	hitbox = hitbox_scene.instance()
	hitbox.display("Current health: " + str(stats["current_health"]))

func register(world):
  world.add_child(hitbox)

func update(new_state):
  hitbox.position = new_state[si.PLAYER_POSITION]

func remove():
  hitbox.get_parent().remove_child(hitbox)
  hitbox.queue_free()

func get_position():
	return hitbox.position

func mock_stats():
	stats["current_health"] = 100
	stats["max_health"] = 100
	stats["attack"] = 150

func take_damage(value):
	var current_health =  stats["current_health"]
	current_health = max(0, current_health - value)
	stats["current_health"] = current_health
	hitbox.display("Current health: " + str(current_health))
