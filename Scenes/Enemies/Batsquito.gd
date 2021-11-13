extends Enemy

func ready():
	type = ServerInterface.EnemyType.BATSQUITO
	.ready()
	item_drop_pool = [5,6,7]
