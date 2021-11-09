extends KinematicBody2D
class_name Enemy

const TIMEOUT_VARIANCE = 2
const DESPAWN_TIME = 5

var si = ServerInterface
var pars = EnemyParameters.new()
var item_drop_pool : Array
var tagged_by_player : int = 0



enum State {
	IDLE,
	WANDER,
	CHASE,
	ATTACK,
	ATTACK_COOLDOWN,
	EVADE,
	DEAD,
	DESPAWN
}

var state
onready var map = get_node("/root/Server/Map")
onready var server_map = get_node("/root/Server/ServerMap")


var idle_timer : BasicTimer = BasicTimer.new()
var wander_timer : BasicTimer = BasicTimer.new()
var attack_timer : BasicTimer = BasicTimer.new()
var attack_delay : BasicTimer = BasicTimer.new()
var despawn_timer : BasicTimer = BasicTimer.new()
var tagged_timer : BasicTimer = BasicTimer.new()
var wander_target
var spawn_point
var target
var dropped_items : bool = false

var status_dict : Dictionary
func set_status_dict(dict):
	status_dict = dict
	
func _ready():
	spawn_point = position
	enter_state(State.IDLE)

func take_damage(value : float, attacker : int):
	#either the monster is not tagger or check if its the same player, if so reset timer for tagged
	if tagged_by_player == 0 or attacker == tagged_by_player:
		player_tag_enemy(attacker)
	if status_dict == null:
		# something went wrong, the enemy is not registered in the server
		return

	if status_dict[si.ENEMY_CURRENT_HEALTH] <= 0:
		pass
	else:
		status_dict[si.ENEMY_CURRENT_HEALTH] -= value
		if status_dict[si.ENEMY_CURRENT_HEALTH] <= 0:
			enter_state(State.DEAD)

func player_tag_enemy(attacker: int):
	tagged_by_player = attacker
	Logger.info("Tagged by playerID: %d" % [tagged_by_player])
	tagged_timer.start(5)
	
	
var velocity : Vector2 = Vector2()

func process_state(delta):
	match state:
		State.DESPAWN:
			return
		State.DEAD:
			despawn_timer.advance(delta)
			if despawn_timer.is_timed_out():
				enter_state(State.DESPAWN)
			if not dropped_items:
				var pick_random_item = randi() % 3 
				#add drop table to the potential item ids here, with weighting eg boots drop more than epic sword
				server_map.spawn_item_drop(tagged_by_player, position, item_drop_pool[pick_random_item])
				dropped_items = true
				pass
			
		State.IDLE:
			idle_timer.advance(delta)
			if idle_timer.is_timed_out():
				enter_state(State.WANDER)

		State.WANDER:
			wander_timer.advance(delta)
			if wander_timer.is_timed_out():
				enter_state(State.IDLE)
			else:
				var diff = (wander_target - position)
				if diff.length_squared() < 4:
					enter_state(State.IDLE)
				else:
					velocity = diff.normalized() * pars.get(EnemyParameters.WANDER_SPEED) * delta
		State.CHASE:
			var destination = Players.get_player_position(target)
			if destination == null:
				Logger.info("%s: Enemy %s - chase ended, player disconnected" % [filename, name])
				enter_state(State.EVADE)
			else:
				if (destination - spawn_point).length() > pars.get(EnemyParameters.CHASE_RANGE):
					Logger.info("%s: Enemy %s - chase ended: too far from spawn" % [filename, name])
					# moved too far from spawn point, return to spawn
					enter_state(State.EVADE)
				else:
					var diff : Vector2 = destination - position
					if diff.length_squared() < pow(pars.get(EnemyParameters.ATTACK_RANGE), 2):
						velocity = Vector2.ZERO
						enter_state(State.ATTACK)
					else:
						velocity = (destination - position).normalized() * pars.get(EnemyParameters.CHASE_SPEED) * delta
		State.ATTACK:
			velocity = Vector2.ZERO
			attack_delay.advance(delta)
			if attack_delay.is_timed_out():
				perform_attack()
				enter_state(State.ATTACK_COOLDOWN)
		State.ATTACK_COOLDOWN:
			velocity = Vector2.ZERO
			attack_timer.advance(delta)
			if attack_timer.is_timed_out():
				enter_state(State.CHASE, target)
		State.EVADE:
			velocity = (spawn_point - position).normalized() * pars.get(EnemyParameters.WANDER_SPEED) * delta
			# When evading, enemies avoid collision and are untargetable
			collision_layer = 0x0
			if (position - spawn_point).length() < 2:
				enter_state(State.IDLE)
	
	if tagged_by_player != 0:
		tagged_timer.advance(delta)
		if tagged_timer.is_timed_out():
			tagged_by_player = 0
		
func enter_state(new_state, extra_data = null):
#	Logger.info("%s: Enemy %s (%s) entered new state: %s" % [filename, name, status_dict[si.ENEMY_TYPE], State.keys()[new_state]])
		
	# Currently client is informed of all states. Maybe change in the future?
	
	match new_state:
		State.IDLE:
			velocity = Vector2.ZERO
			collision_layer = 0x4
			idle_timer.start(pars.get(EnemyParameters.IDLE_TIMEOUT) + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
		State.WANDER:
			velocity = Vector2.ZERO
			select_wander_target()
			wander_timer.start(pars.get(EnemyParameters.WANDER_TIMEOUT) + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
		State.CHASE:
			if extra_data != null:
				target = extra_data
		State.ATTACK_COOLDOWN:
			attack_timer.start(pars.get(EnemyParameters.TIME_BETWEEN_ATTACKS))
		State.ATTACK:
			attack_delay.start(0.5)
		State.DEAD:
			despawn_timer.start(DESPAWN_TIME)
		State.DESPAWN:
			var id = int(name)
			map.release_occupied_location(id)
			queue_free()
		State.EVADE:
			pass
		_:
			# Handling of other states should be implemented in subclasses
			assert(false)
	
	status_dict[si.ENEMY_STATE] = new_state
	state = new_state


func select_wander_target():
	wander_target = spawn_point + (Vector2.ONE * pars.get(EnemyParameters.WANDER_TARGET_RANGE)).rotated(deg2rad(randi() % 360))

func perform_attack():
	var player = Players.get_player(target)
	if player:
		player.take_damage(3, target)

func seek_player():
	var aggro_range : CircleShape2D = CircleShape2D.new()
	aggro_range.radius = pars.get(EnemyParameters.AGGRO_RANGE)
	var query : Physics2DShapeQueryParameters = Physics2DShapeQueryParameters.new()
	query.set_shape(aggro_range)
	query.transform = Transform2D(0, position)
	query.collision_layer = 0x2
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var space = get_world_2d().direct_space_state
	var result : Array = space.intersect_shape(query)
	if result.size() > 0:
		enter_state(State.CHASE, result[0]["collider"].id)
