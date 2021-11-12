extends Enemy

func ready():
	type = ServerInterface.EnemyType.SLIME
	.ready()
	item_drop_pool = [5,6,7]

