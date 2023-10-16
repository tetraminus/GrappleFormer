extends Node2D
@onready var ray: RayCast2D = %RayCast2D
@onready var attachpoint:DampedSpringJoint2D = %GrapplingHookAttachPoint
@onready var EndPrefab = preload("res://Grapple/RopeSegment.tscn")

var current_grapple = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	look_at(get_global_mouse_position())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouse:
		ray.target_position = get_global_mouse_position()


	if Input.is_action_just_pressed("grapple"):
		ray.force_raycast_update()
		if ray.is_colliding():
			var point = ray.get_collision_point()
			var distance = ray.get_collision_point().distance_to(attachpoint.global_position)

			var end = EndPrefab.instance()
			end.global_position = point
			get_tree().get_root().add_child(end)
			current_grapple = end

			attachpoint.node_b = end
			attachpoint.length = distance
			attachpoint.rest_length = distance



			
			
			
			

	


	
