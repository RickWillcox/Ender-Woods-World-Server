extends Enemy

onready var game_server_script = get_node("../../../../../Server")


enum ATTACK_TYPES {
	ATTACKSWING,
	ATTACKSPIN,
	NOTATTACKING		
}

var rng

func _ready():
	randomize()
	item_drop_pool = [1,2,3]
	rng = RandomNumberGenerator.new()
	
	pars.set(EnemyParameters.CHASE_SPEED, 2000)
	
	# The minotaur is restless, he seeks out players
	pars.set(EnemyParameters.IDLE_TIMEOUT, 0.5)
	pars.set(EnemyParameters.WANDER_SPEED, 1500)
	pars.set(EnemyParameters.WANDER_TARGET_RANGE, 150)
	
func _physics_process(delta):
	if state in [Enemy.State.DESPAWN]:
		return
	else:
		.process_state(delta)
	match state:
		Enemy.State.IDLE, Enemy.State.WANDER:
			seek_player()

	status_dict[si.ENEMY_LOCATION] = position
	velocity = move_and_slide(velocity)

func perform_attack():
	rng.randomize()
	var num = rng.randi_range(0,1)
	if num == 0:
		game_server_script.enemy_attack(name, ATTACK_TYPES.ATTACKSWING)
	elif num == 1:
		game_server_script.enemy_attack(name, ATTACK_TYPES.ATTACKSPIN)
