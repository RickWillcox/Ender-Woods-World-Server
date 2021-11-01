extends Enemy

onready var animation_tree = $MinoAnimationTree
onready var animation_state = $MinoAnimationTree.get("parameters/playback")
onready var wander_controller = $WanderController
onready var player_detection_zone = $PlayerDetectionZone
onready var game_server_script = get_node("../../../../../Server")


enum{
	LEFT, 
	RIGHT
}

enum ATTACK_TYPES {
	ATTACKSWING,
	ATTACKSPIN,
	NOTATTACKING		
}

var blend_position = Vector2.ZERO
var facing_blend_position = Vector2.ZERO
var attack = ATTACK_TYPES.NOTATTACKING
var previous_state = Enemy.State.IDLE
var rng
var facing = RIGHT



func _ready():
	randomize()
	rng = RandomNumberGenerator.new()
	animation_tree.active = true
	
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
	blend_position()

	velocity = move_and_slide(velocity)

func seek_player():
	if player_detection_zone.can_see_player():
		enter_state(Enemy.State.CHASE, player_detection_zone.player.id)
		
func blend_position():
	var old_blend_position = blend_position
	blend_position = wander_controller.target_position
	if facing == RIGHT:
		if blend_position.x < old_blend_position.x:
			facing = LEFT
			facing_blend_position = blend_position * -1
	elif facing == LEFT:
		if blend_position.x > old_blend_position.x:
			facing = RIGHT
			facing_blend_position = facing_blend_position * -1
	animation_tree.set("parameters/Idle/blend_position", facing_blend_position)
	animation_tree.set("parameters/Run/blend_position", facing_blend_position)
	animation_tree.set("parameters/AttackSwing/blend_position", facing_blend_position)
	animation_tree.set("parameters/AttackSpin/blend_position", facing_blend_position)


func attack(attack_type):
	game_server_script.EnemyAttack(name, attack_type)

func perform_attack():
	rng.randomize()
	var num = rng.randi_range(0,1)
	if num == 0:
		animation_state.travel("AttackSwing") #attack swing
		game_server_script.EnemyAttack(name, ATTACK_TYPES.ATTACKSWING)
	elif num == 1:
		animation_state.travel("AttackSpin") #attack spin
		game_server_script.EnemyAttack(name, ATTACK_TYPES.ATTACKSPIN)
