extends Node2D

var sd = ServerData
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
		body.take_damage(150, player_id)
	elif body.is_in_group("Ores"):
		if ServerData.mining_data[body.name][sd.ACTIVE] == 1:
			if ServerData.mining_data[body.name][sd.CURRENT_HITS] == ServerData.mining_data[body.name][sd.HITS_HP] - 1:
				#node drops item and goes inactive
				ServerData.mining_data[body.name][sd.ACTIVE] = 0
				ServerData.mining_data[body.name][sd.CURRENT_HITS] = 0
			else:
				ServerData.mining_data[body.name][sd.CURRENT_HITS] += 1

