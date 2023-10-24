extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	#set to mouse pos
	if event is InputEventMouseMotion:
		global_position = event.position

func _process(delta):
	global_position = get_global_mouse_position()
	



	



	

	
	
	
	
