extends KinematicBody2D

var sd = ServerData
export var ACCELERATION = 300
export var MAX_SPEED = 250
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 5

onready var animation_tree = $MinoAnimationTree
onready var animation_state = $MinoAnimationTree.get("parameters/playback")
onready var wander_controller = $WanderController
onready var player_detection_zone = $PlayerDetectionZone
onready var map_enemy_list = get_node("../../../../Map")
onready var game_server_script = get_node("../../../../../Server")
onready var attack_timer = $AttackTimer

enum STATES{
	IDLE, 
	WANDER, 
	CHASE, 
	ATTACK, 
	DEAD
}

enum{
	LEFT, 
	RIGHT
}

enum ATTACK_TYPES {
	ATTACKSWING,
	ATTACKSPIN,
	NOTATTACKING		
}

var velocity = Vector2.ZERO
var blend_position = Vector2.ZERO
var facing_blend_position = Vector2.ZERO
var state 
var attack = ATTACK_TYPES.NOTATTACKING
var previous_state = STATES.IDLE
var rng
var facing = RIGHT



func _ready():
	randomize()
	rng = RandomNumberGenerator.new()
	state = pick_random_state([STATES.IDLE, STATES.WANDER, STATES.ATTACK])

	animation_tree.active = true
	
func _physics_process(delta):
	var enemy = map_enemy_list.enemy_list[int(name)]
	if enemy[sd.ENEMY_STATE] == STATES.keys()[STATES.DEAD]:
		pass
	else:
		enemy[sd.ENEMY_LOCATION] = Vector2(int(position.x),int(position.y))  #update enemy position in world state
		blend_position()
#		print(STATES.keys()[state])

		match state:
			STATES.IDLE:
				animation_state.travel("Idle")
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
				seek_player()
				time_left_wander_controller()
				
			STATES.WANDER:
				animation_state.travel("Run")
				seek_player()
				time_left_wander_controller()
				var direction = global_position.direction_to(wander_controller.target_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				
				if global_position.distance_to(wander_controller.target_position) <= WANDER_TARGET_RANGE:
					state = pick_random_state([STATES.IDLE, STATES.WANDER, STATES.ATTACK])
					wander_controller.start_wander_timer(rand_range(1,3))
					
			STATES.CHASE:
				var player = player_detection_zone.player
				if player != null:
					if global_position.distance_to(player.global_position) <= 25 and attack_timer.is_stopped():
						state = STATES.ATTACK
						velocity = Vector2.ZERO
					animation_state.travel("Run")
					var direction = global_position.direction_to(player.global_position)
					velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				else:
					state = STATES.IDLE
				
			STATES.ATTACK:
				#set attack type here
				if attack_timer.is_stopped(): #is the timer running? if yes it means an attack is being played.
					rng.randomize()
					var num = rng.randi_range(0,1)		
					if num == 0:
						attack_timer.wait_time = 1.9
						animation_state.travel("AttackSwing") #attack swing
						game_server_script.EnemyAttack(name, ATTACK_TYPES.ATTACKSWING)
					elif num == 1:
						attack_timer.wait_time = 1.1
						animation_state.travel("AttackSpin") #attack spin
						game_server_script.EnemyAttack(name, ATTACK_TYPES.ATTACKSPIN)
					attack_timer.start()
					
					
		velocity = move_and_slide(velocity)
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func seek_player():
	if player_detection_zone.can_see_player():
		state = STATES.CHASE
		
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

func time_left_wander_controller():
	if wander_controller.get_time_left() == 0:
		state = pick_random_state([STATES.IDLE, STATES.WANDER, STATES.ATTACK])
		wander_controller.start_wander_timer(rand_range(1,3))

func attack(attack_type):
	game_server_script.EnemyAttack(name, attack_type)

func _on_AttackTimer_timeout() -> void:
	state = STATES.IDLE

	
