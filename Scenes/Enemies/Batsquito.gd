extends Enemy

func ready():
	type = ServerInterface.EnemyType.BATSQUITO
	.ready()
	item_drop_pool = [81,82,83,84,85]
