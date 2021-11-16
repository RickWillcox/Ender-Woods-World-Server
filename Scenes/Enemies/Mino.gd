extends Enemy

func ready():
	type = si.EnemyType.MINO
	.ready()
	# Drops all Iron and Bronze Gear
	item_drop_pool = [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
					  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51]
	
	pars.set(EnemyParameters.CHASE_SPEED, 2000)
	
	# The minotaur is restless, he seeks out players
	pars.set(EnemyParameters.IDLE_TIMEOUT, 0.5)
	pars.set(EnemyParameters.WANDER_SPEED, 1500)
	pars.set(EnemyParameters.WANDER_TARGET_RANGE, 150)
	pars.set(EnemyParameters.STANCE, EnemyParameters.Stance.AGGRESIVE)
	
func _physics_process(delta):
	process_state(delta)
