extends Enemy

const WANDER_SPEED = 300
const CHASE_SPEED = 700
const WANDER_TARGET_RANGE = 50
const ATTACK_RANGE = 30
const IDLE_TIMEOUT = 5
const WANDER_TIMEOUT = 5
const TIMEOUT_VARIANCE = 2
const TIME_BETWEEN_ATTACKS = 1.5

onready var map_enemy_list = get_node("../../../../Map")
onready var game_server_script = get_node("../../../../../Server")

enum STATES{
	IDLE,
	WANDER,
	CHASE,
	ATTACK_COOLDOWN,
	DEAD
}

class BasicTimer:
	var timeout
	var time
	func start(_timeout):
		time = 0
		timeout = _timeout
	func advance(delta):
		time += delta
	func is_timed_out():
		return time > timeout

var velocity = Vector2.ZERO
var state

var idle_timer = BasicTimer.new()
var wander_timer = BasicTimer.new()
var attack_timer = BasicTimer.new()
var spawn_point : Vector2
var wander_target : Vector2
var target
func _ready():
	spawn_point = position
	enter_state(STATES.IDLE)

func enter_state(new_state, extra_data = null):
	if new_state == STATES.IDLE:
		velocity = Vector2.ZERO
		idle_timer.start(IDLE_TIMEOUT + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
	elif new_state == STATES.WANDER:
		velocity = Vector2.ZERO
		select_wander_target()
		wander_timer.start(WANDER_TIMEOUT + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
	elif new_state == STATES.CHASE:
		target = extra_data
	elif new_state == STATES.ATTACK_COOLDOWN:
		attack_timer.start(TIME_BETWEEN_ATTACKS)
	state = new_state


func _physics_process(delta):
	if status_dict[si.ENEMY_STATE] == STATES.keys()[STATES.DEAD]:
		pass
	else:
		status_dict[si.ENEMY_LOCATION] = position

		match state:
			STATES.IDLE:
				if idle_timer.is_timed_out():
					enter_state(STATES.WANDER)
				else:
					idle_timer.advance(delta)

			STATES.WANDER:
				if wander_timer.is_timed_out():
					enter_state(STATES.IDLE)
				else:
					var diff = (wander_target - position)
					if diff.length_squared() < 4:
						enter_state(STATES.IDLE)
					else:
						velocity = diff.normalized() * WANDER_SPEED * delta
				wander_timer.advance(delta)
			STATES.CHASE:
				if (position - spawn_point).length() > 100:
					# moved too far from spawn point, return to spawn
					enter_state(STATES.WANDER)
				else:
					var destination = Players.get_player_position(target)
					if destination == null:
						enter_state(STATES.WANDER)
					else:
						var diff : Vector2 = destination - position
						if diff.length_squared() < ATTACK_RANGE * ATTACK_RANGE:
							velocity = Vector2.ZERO
							Players.get_player(target).take_damage(3)
							enter_state(STATES.ATTACK_COOLDOWN)
						else:
							velocity = (destination - position).normalized() * CHASE_SPEED * delta
			STATES.ATTACK_COOLDOWN:
				velocity = Vector2.ZERO
				if attack_timer.is_timed_out():
					enter_state(STATES.CHASE, target)
				else:
					attack_timer.advance(delta)

		velocity = move_and_slide(velocity)

func select_wander_target():
	wander_target = spawn_point + (Vector2.ONE * WANDER_TARGET_RANGE).rotated(deg2rad(randi() % 360))

func take_damage(value : float, attacker):
	.take_damage(value, attacker)
	enter_state(STATES.CHASE, attacker)
