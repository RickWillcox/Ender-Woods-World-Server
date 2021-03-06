extends KinematicBody2D
class_name Enemy

const TIMEOUT_VARIANCE = 2
const DESPAWN_TIME = 5
const ENEMY_COLLISION_MASK = 0b1001
const ENEMY_COLLISION_LAYER = 0b100

var si = ServerInterface
var pars = EnemyParameters.new()
var item_drop_pool : Array
var tagged_by_player : int = 0
var type

# A set of sub-states is needed
var is_attacking : bool = false

enum State {
	IDLE,
	WANDER,
	ENGAGED,
	EVADE,
	DEAD,
	DESPAWN
}

var state

onready var server_map = get_node("/root/Server/ServerMap")
onready var server = get_node("/root/Server")


var idle_timer : BasicTimer = BasicTimer.new()
var wander_timer : BasicTimer = BasicTimer.new()
var attack_swing_timer : Timer = Timer.new()
var damage_delay_timer : Timer = Timer.new()
var despawn_timer : BasicTimer = BasicTimer.new()
var tagged_timer : BasicTimer = BasicTimer.new()
var wander_target
var spawn_point
var target
var dropped_items : bool = false

var status_dict : Dictionary
func set_status_dict(dict):
	status_dict = dict

# dont use _ready because it has weird behavior
func ready():
	spawn_point = position
	enter_state(State.IDLE)
	add_child(damage_delay_timer)
	add_child(attack_swing_timer)

	attack_swing_timer.connect("timeout",self,"attack_swing_finished")
	attack_swing_timer.one_shot = true

	damage_delay_timer.connect("timeout", self, "perform_attack")
	damage_delay_timer.one_shot = true
	server.broadcast_packet(Players.get_players(),
		si.create_enemy_spawn_packet(int(name), si.EnemyState.ALIVE, type, status_dict[si.ENEMY_CURRENT_HEALTH], position))

func _ready():
	ready()

func take_damage(value : float, attacker : int):
	if state in [State.EVADE, State.DEAD, State.DESPAWN]:
		return
	
	#either the monster is not tagger or check if its the same player, if so reset timer for tagged
	if tagged_by_player == 0 or attacker == tagged_by_player:
		player_tag_enemy(attacker)
	if status_dict == null:
		# something went wrong, the enemy is not registered in the server
		return

	server.broadcast_packet(Players.get_players(),
		si.create_enemy_take_damage_packet(attacker, int(name), value))

	if status_dict[si.ENEMY_CURRENT_HEALTH] <= 0:
		pass
	else:
		status_dict[si.ENEMY_CURRENT_HEALTH] -= value
		if status_dict[si.ENEMY_CURRENT_HEALTH] <= 0:
			enter_state(State.DEAD)
		
	if not state in [State.DEAD, State.ENGAGED]:
		enter_state(State.ENGAGED, attacker)

func player_tag_enemy(attacker: int):
	tagged_by_player = attacker
#	Logger.info("Tagged by playerID: %d" % [tagged_by_player])
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
				var pick_random_item = randi() % item_drop_pool.size() - 1
				#add drop table to the potential item ids here, with weighting eg boots drop more than epic sword
				server_map.spawn_item_drop(tagged_by_player, position, item_drop_pool[pick_random_item])
				dropped_items = true
				pass

		State.IDLE:
			idle_timer.advance(delta)
			if idle_timer.is_timed_out():
				enter_state(State.WANDER)
			elif pars.get(EnemyParameters.STANCE) == EnemyParameters.Stance.AGGRESIVE:
				seek_player()

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
					if pars.get(EnemyParameters.STANCE) == EnemyParameters.Stance.AGGRESIVE:
						seek_player()
		State.ENGAGED:
			var player = Players.get_player(target)
			if not should_evade():
				var destination = player.get_position()
				var diff : Vector2 = destination - position

				# Use length_squared instead of length for performance reasons
				velocity = Vector2.ZERO
				if diff.length_squared() < pow(pars.get(EnemyParameters.ATTACK_RANGE), 2):
					attack_if_ready()
				elif not is_attacking: # wait until the swing animation is finished to move
					velocity = (destination - position).normalized() * pars.get(EnemyParameters.CHASE_SPEED) * delta
		State.EVADE:
			if (position - spawn_point).length_squared() < 4:
				enter_state(State.IDLE)
			else:
				velocity = (spawn_point - position).normalized() * pars.get(EnemyParameters.WANDER_SPEED) * delta
				velocity = velocity.clamped((spawn_point - position).length())

	if tagged_by_player != 0:
		tagged_timer.advance(delta)
		if tagged_timer.is_timed_out():
			tagged_by_player = 0

func enter_state(new_state, extra_data = null):
#	Logger.info("%s: Enemy %s (%s) entered new state: %s" % [filename, name, status_dict[si.ENEMY_TYPE], State.keys()[new_state]])

	match new_state:
		State.IDLE:
			velocity = Vector2.ZERO
			# if just entered idle from evade, restore collisions
			if state == State.EVADE:
				collision_layer = ENEMY_COLLISION_LAYER
				collision_mask = ENEMY_COLLISION_MASK
			idle_timer.start(pars.get(EnemyParameters.IDLE_TIMEOUT) + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
		State.WANDER:
			velocity = Vector2.ZERO
			select_wander_target()
			wander_timer.start(pars.get(EnemyParameters.WANDER_TIMEOUT) + randf() * TIMEOUT_VARIANCE - TIMEOUT_VARIANCE / 2)
		State.ENGAGED:
			if extra_data != null:
				target = extra_data
		State.DEAD:
			despawn_timer.start(DESPAWN_TIME)
			server.broadcast_packet(Players.get_players(),
				si.create_enemy_died_packet(int(name)))
		State.DESPAWN:
			server.broadcast_packet(Players.get_players(),
				si.create_enemy_despawn_packet(int(name)))
			var id = int(name)
			EnemySpawnData.open_spawn_location(id)
			queue_free()
		State.EVADE:
			# When evading, enemies avoid collision and are untargetable
			collision_layer = 0x0
			collision_mask = 0x0
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
		player.take_damage(3, int(name))

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
		enter_state(State.ENGAGED, result[0]["collider"].id)

func should_evade():
	var destination = Players.get_player_position(target)
	if destination == null:
#		Logger.info("%s: Enemy %s - chase ended, player disconnected" % [filename, name])
		enter_state(State.EVADE)
		return true
	else:
		if (destination - spawn_point).length() > pars.get(EnemyParameters.CHASE_RANGE):
#			Logger.info("%s: Enemy %s - chase ended: too far from spawn" % [filename, name])
			# moved too far from spawn point, return to spawn
			enter_state(State.EVADE)
			return true
	return false

func attack_if_ready():
	if is_attacking:
		return
	else:
		is_attacking = true
		perform_swing()
		attack_swing_timer.start(2) # attack speed
		damage_delay_timer.start(0.5) # When the damage actually arrives


func perform_swing():
	server.broadcast_packet(Players.get_players(),
		si.create_enemy_attack_swing_packet(int(name), target))

func attack_swing_finished():
	is_attacking = false

func perfrom_attack():
	# can only attack if still engaged
	if state == State.ENGAGED:
		server.broadcast_packet(Players.get_players(),
			si.create_player_take_damage_packet(int(name), target, 3)) # damage


func _physics_process(delta):
	process_state(delta)
	
	status_dict[si.ENEMY_LOCATION] = position
	velocity = move_and_slide(velocity)


# create current state packet
func get_state_packet():
	var si_state = si.EnemyState.ALIVE
	var health = status_dict[si.ENEMY_CURRENT_HEALTH]
	if state == State.DEAD:
		si_state = si.EnemyState.DEAD
		health = 0
	return si.create_enemy_spawn_packet(int(name), si_state, type, health, position)
