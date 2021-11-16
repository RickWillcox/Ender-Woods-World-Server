extends Ore

var type = ServerInterface.GOLD_ORE

func _ready() -> void:
	ore_type = type
	._ready()
	item_drop_pool = [100005]
	
