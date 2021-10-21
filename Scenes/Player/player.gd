extends Node
class_name Player

var hitbox : StaticBody2D

func initialize(init_state):
	hitbox = StaticBody2D.new()
	hitbox.position = init_state[ServerData.PLAYER_POSITION]
	hitbox.collision_layer = 0x2
	hitbox.collision_mask = 0x0
	var label = Label.new()
	label.text = "Player"
	hitbox.add_child(label)
	var collision_shape = CollisionShape2D.new()
	collision_shape.position.y -= 20
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(20, 20)
	collision_shape.shape = shape
	hitbox.add_child(collision_shape)
  
func register(world):
  world.add_child(hitbox)

func update(new_state):
  hitbox.position = new_state[ServerData.PLAYER_POSITION]
  
func remove():
  hitbox.get_parent().remove_child(hitbox)
  hitbox.queue_free()
