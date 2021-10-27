extends StaticBody2D

var si = ServerInterface
var respawn_timer_active = false

func _physics_process(_delta):
	if ServerData.woodcutting_data[self.name][si.ACTIVE] == 0:
		if not respawn_timer_active:
			respawn_timer_active = true
			yield(get_tree().create_timer(ServerData.woodcutting_data[self.name][si.RESPAWN]),"timeout")
			respawn_timer_active = false
			ServerData.woodcutting_data[self.name][si.ACTIVE] = 1
		
