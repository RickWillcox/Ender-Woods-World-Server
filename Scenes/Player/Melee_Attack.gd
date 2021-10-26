extends Node2D

var player_id
var blend_position
onready var animation_player = get_node("AnimationPlayer")
onready var melee_hitbox = get_node("Pivot/Area2D/MeleeHitbox")
onready var melee_attack_scene

func change_rotation(blend_position):
	var animation_tree = get_node("AnimationTree")
	animation_tree.set("parameters/Hitbox_Rotation/blend_position", blend_position)


func _on_Timer_timeout() -> void:
	queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		# TODO: damage calculation based on player stats and items
		var damage = 150
		body.take_damage(damage, player_id)
	elif body.is_in_group("Ores"):
		body.take_damage(1, player_id)
