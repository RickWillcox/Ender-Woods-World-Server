extends "res://addons/gut/test.gd"
var mino_scene = load("res://Scenes/Enemies/Mino.tscn")

# this tests that enemies dont overshoot their spawn point when returning from
# evade to idle
func test_enemy_no_idle_overshoot():
	var mino : Enemy = mino_scene.instance()
	mino.spawn_point = Vector2(0.0, 0.0)
	mino.position = Vector2(2.01, 0.0)
	
	# mino tries to return to spawn
	mino.enter_state(Enemy.State.EVADE)
	
	mino._physics_process(0.125)
	mino.position += mino.velocity # simulate physics movement
	assert_eq(mino.state, Enemy.State.EVADE)
	mino._physics_process(0.125)
	
	# mino is very close to spawn so it should just enter idle state
	assert_eq(mino.state, Enemy.State.IDLE)
	mino.queue_free()
