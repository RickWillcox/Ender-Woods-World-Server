extends Enemy

func ready():
	# Change to EnemyType.MINO for example
	type = si.EnemyType.DEER
	.ready()
	# Item IDs to drop eg [1, 2, 5, 6]
	item_drop_pool = [61, 62, 63, 64, 65]
	
	# Set custom enemy parameters here
	pars.set(EnemyParameters.CHASE_SPEED, 2000)
	pars.set(EnemyParameters.IDLE_TIMEOUT, 0.5)
	pars.set(EnemyParameters.WANDER_SPEED, 1500)
	pars.set(EnemyParameters.WANDER_TARGET_RANGE, 200)
	pars.set(EnemyParameters.STANCE, EnemyParameters.Stance.PASSIVE)
	pars.set(EnemyParameters.ATTACK_RANGE, 100)

	
func _physics_process(delta):
	process_state(delta)
