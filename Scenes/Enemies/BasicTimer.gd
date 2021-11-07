extends Node
class_name BasicTimer

var timeout : float
var time : float

func start(_timeout : float):
	time = 0
	timeout = _timeout

func advance(delta : float):
	time += delta
	
func is_timed_out():
	return time > timeout
