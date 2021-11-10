extends Enemy

func ready():
	.ready()
	item_drop_pool = [5,6,7]

func enter_state(new_state, extra_data = null):
	if new_state == Enemy.State.ENGAGED:
		target = extra_data
	.enter_state(new_state)

func _physics_process(delta):
	match state:
		Enemy.State.DESPAWN:
			return
	
	.process_state(delta)		
	
	status_dict[si.ENEMY_LOCATION] = position
	velocity = move_and_slide(velocity)

func take_damage(value : float, attacker):
	if state in [Enemy.State.EVADE, Enemy.State.DEAD, Enemy.State.DESPAWN]:
		return
	.take_damage(value, attacker)
	if not state in [Enemy.State.DEAD]:
		enter_state(Enemy.State.ENGAGED, attacker)

