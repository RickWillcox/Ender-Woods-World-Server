extends Enemy

func ready():
	type = ServerInterface.EnemyType.BATSQUITO
	.ready()
	# Drops all Silver and Gold Gear
	item_drop_pool = [61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71,
					  81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91]
