extends Enemy

func ready():
	type = ServerInterface.EnemyType.SLIME
	.ready()
	item_drop_pool = [61, 62, 63, 64, 65, 66, 67]