extends StaticBody2D
var id
func display(text):
	$Label.text = text

func _ready():
	name = str(id)
