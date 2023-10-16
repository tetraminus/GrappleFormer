extends Node2D
@onready var ray: RayCast2D = $RayCast2D


var current_grapple = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	look_at(get_global_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	


	if Input.is_action_just_pressed("grapple"):
		ray.force_raycast_update()
		if ray.is_colliding():
			var point = ray.get_collision_point()
			var distance = ray.get_collision_point().distance_to(owner.position)

			owner.grapplepoint = point
			owner.grappledistance = distance

	if Input.is_action_just_released("grapple"):
		owner.grapplepoint = null
		owner.grappledistance = null



			
			
			
			

	


	
