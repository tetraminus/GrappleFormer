extends Node2D
@onready var ray: RayCast2D = $RayCast2D
@export var grappledistance:int
@export var grapplespeed:int
var player
@onready var fling_indicator = %flingIndicator
var fling_pos: Vector2 = Vector2(0, 0)


# Called when the node enters the scene tree for the first time.
func _ready():
	ray.target_position = Vector2(grappledistance,0)
	player = owner as Player
	#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
	

func _process(_delta):

	look_at(get_global_mouse_position())
	if ray.is_colliding():
		fling_pos = ray.get_collision_point()
	if player.grapplepoint == null:
		
		
		fling_indicator.global_position = fling_indicator.global_position.lerp(fling_pos, 0.5)
			

			
	else:
		fling_indicator.global_position = player.grapplepoint
		
	
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(_event):
	

	if Input.is_action_just_pressed("grapple"):
		ray.force_raycast_update()

		
		if true:
			
			var point = fling_pos

			var distance = fling_pos.distance_to(owner.position)
			
			if distance < grappledistance:
				player.setgrapple(point, distance)
			
			if ray.get_collision_mask_value(3):
				return
			
			
			

	if Input.is_action_just_released("grapple"):
		player.releasegrapple()
	
	if Input.is_action_just_pressed("grapplefling"):
		player.grapplefling(grapplespeed)

			
			
			
			

	


	
