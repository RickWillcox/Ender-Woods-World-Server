extends Enemy

const MAX_SPEED = 300
const WANDER_TARGET_RANGE = 50
const ATTACK_RANGE = 15
const IDLE_TIMEOUT = 5
const WANDER_TIMEOUT = 5
const TIMEOUT_VARIANCE = 2

onready var map_enemy_list = get_node("../../../../Map")
onready var game_server_script = get_node("../../../../../Server")

enum STATES{
	IDLE, 
	WANDER,
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
var spawn_point : Vector2
var wander_target : Vector2
var target
func _ready():
	spawn_point = position
	enter_state(STATES.IDLE)

func enter_state(new_state):
	if new_state == STATES.IDLE:
		velocity = Vector2.ZERO
		idle_timer.start(IDLE_TIMEOUT + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
	elif new_state == STATES.WANDER:
		select_wander_target()
		wander_timer.start(WANDER_TIMEOUT + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
	state = new_state
		
	
func _physics_process(delta):
	var enemy = map_enemy_list.enemy_list[int(name)]
	if enemy[ServerData.ENEMY_STATE] == STATES.keys()[STATES.DEAD]:
		pass
	else:
		enemy[ServerData.ENEMY_LOCATION] = position
		
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
						velocity = diff.normalized() * MAX_SPEED * delta
				wander_timer.advance(delta)	
		velocity = move_and_slide(velocity)

func select_wander_target():
	wander_target = spawn_point + (Vector2.ONE * WANDER_TARGET_RANGE).rotated(deg2rad(randi() % 360))
	
