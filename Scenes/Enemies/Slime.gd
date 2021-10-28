extends Enemy

const WANDER_SPEED = 300
const CHASE_SPEED = 700
const WANDER_TARGET_RANGE = 50
const ATTACK_RANGE = 30
const IDLE_TIMEOUT = 5
const WANDER_TIMEOUT = 5
const TIMEOUT_VARIANCE = 2
const TIME_BETWEEN_ATTACKS = 1.5
const CHASE_RANGE = 300

var velocity = Vector2.ZERO
var state

var idle_timer = BasicTimer.new()
var wander_timer = BasicTimer.new()
var attack_timer = BasicTimer.new()
var despawn_timer = BasicTimer.new()
var attack_delay = BasicTimer.new()

var spawn_point : Vector2
var wander_target : Vector2
var target
func _ready():
	spawn_point = position
	enter_state(Enemy.State.IDLE)

func enter_state(new_state, extra_data = null):
	print([name, " entering new state: ", new_state])
	if new_state == Enemy.State.IDLE:
		velocity = Vector2.ZERO
		collision_layer = 0x4
		idle_timer.start(IDLE_TIMEOUT + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
	elif new_state == Enemy.State.WANDER:
		velocity = Vector2.ZERO
		select_wander_target()
		wander_timer.start(WANDER_TIMEOUT + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
	elif new_state == Enemy.State.CHASE:
		target = extra_data
	elif new_state == Enemy.State.ATTACK_COOLDOWN:
		attack_timer.start(TIME_BETWEEN_ATTACKS)
	elif new_state == Enemy.State.DEAD:
		despawn_timer.start(5)
	elif new_state == Enemy.State.DESPAWN:
		var id = int(name)
		map.release_occupied_location(id)
		queue_free()
	elif new_state == Enemy.State.ATTACK:
		attack_delay.start(0.5)

	# Currently client is informed of all states. Maybe change in the future?
	status_dict[si.ENEMY_STATE] = new_state
	
	state = new_state

func _physics_process(delta):
	match state:
		Enemy.State.DESPAWN:
			return
		Enemy.State.DEAD:
			despawn_timer.advance(delta)
			if despawn_timer.is_timed_out():
				enter_state(Enemy.State.DESPAWN)
		Enemy.State.IDLE:
			if idle_timer.is_timed_out():
				enter_state(Enemy.State.WANDER)
			else:
				idle_timer.advance(delta)

		Enemy.State.WANDER:
			if wander_timer.is_timed_out():
				enter_state(Enemy.State.IDLE)
			else:
				var diff = (wander_target - position)
				if diff.length_squared() < 4:
					enter_state(Enemy.State.IDLE)
				else:
					velocity = diff.normalized() * WANDER_SPEED * delta
			wander_timer.advance(delta)
		Enemy.State.CHASE:
			if (position - spawn_point).length() > CHASE_RANGE:
				# moved too far from spawn point, return to spawn
				enter_state(Enemy.State.EVADE)
			else:
				var destination = Players.get_player_position(target)
				if destination == null:
					enter_state(Enemy.State.EVADE)
				else:
					var diff : Vector2 = destination - position
					if diff.length_squared() < ATTACK_RANGE * ATTACK_RANGE:
						velocity = Vector2.ZERO
						enter_state(Enemy.State.ATTACK)
					else:
						velocity = (destination - position).normalized() * CHASE_SPEED * delta
		Enemy.State.ATTACK:
			velocity = Vector2.ZERO
			attack_delay.advance(delta)
			if attack_delay.is_timed_out():
				Players.get_player(target).take_damage(3)
				enter_state(Enemy.State.ATTACK_COOLDOWN)
		Enemy.State.ATTACK_COOLDOWN:
			velocity = Vector2.ZERO
			attack_timer.advance(delta)
			if attack_timer.is_timed_out():
				enter_state(Enemy.State.CHASE, target)
		Enemy.State.EVADE:
			velocity = (spawn_point - position).normalized() * WANDER_SPEED * delta
			# When evading, enemies avoid collision and are untargetable
			collision_layer = 0x0
			if (position - spawn_point).length() < 2:
				enter_state(Enemy.State.IDLE)

	status_dict[si.ENEMY_LOCATION] = position
	velocity = move_and_slide(velocity)

func select_wander_target():
	wander_target = spawn_point + (Vector2.ONE * WANDER_TARGET_RANGE).rotated(deg2rad(randi() % 360))

func take_damage(value : float, attacker):
	if state in [Enemy.State.EVADE, Enemy.State.DEAD, Enemy.State.DESPAWN]:
		return
	enter_state(Enemy.State.CHASE, attacker)
	.take_damage(value, attacker)
