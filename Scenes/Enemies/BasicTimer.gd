extends Node
class_name BasicTimer

var timeout
var time
func start(_timeout):
	time = 0
	timeout = _timeout
func advance(delta):
	time += delta
func is_timed_out():
	return time > timeout
