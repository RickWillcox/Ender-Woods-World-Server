extends Enemy

func ready():
	type = ServerInterface.EnemyType.SLIME
	.ready()
	# Drops all Copper Gear
	item_drop_pool = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
