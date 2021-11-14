extends Enemy

func ready():
	type = si.EnemyType.MINO
	.ready()
	item_drop_pool = [1,2,3,4,5,
					12,13,14,15,16,
					23,24,25,26,27,
					34,35,36,37,39,40,44,
					45,46,47,48,49]
	
	pars.set(EnemyParameters.CHASE_SPEED, 2000)
	
	# The minotaur is restless, he seeks out players
	pars.set(EnemyParameters.IDLE_TIMEOUT, 0.5)
	pars.set(EnemyParameters.WANDER_SPEED, 1500)
	pars.set(EnemyParameters.WANDER_TARGET_RANGE, 150)
	pars.set(EnemyParameters.STANCE, EnemyParameters.Stance.AGGRESIVE)
	
func _physics_process(delta):
	process_state(delta)
