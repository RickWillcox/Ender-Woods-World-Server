extends Node2D

func _ready():
	EnemySpawnData.add_spawn_locations_to_enemy_spawn_data()
	EnemySpawnData.add_respawn_timers()
