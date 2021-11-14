extends Enemy

func ready():
	type = ServerInterface.EnemyType.SLIME
	.ready()
	item_drop_pool = [1,2,3,4,5,
					12,13,14,15,16,
					23,24,25,26,27,
					34,35,36,37,39,40,44,
					45,46,47,48,49]

