extends Node2D
@onready var ray: RayCast2D = $RayCast2D
@export var grappledistance:int
@export var grapplespeed:int
var player
@onready var fling_indicator = %flingIndicator


# Called when the node enters the scene tree for the first time.
func _ready():
	ray.target_position = Vector2(grappledistance,0)
	player = owner as Player
	#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
	

func _process(_delta):
	look_at(get_global_mouse_position())
	if player.grapplepoint == null:
		if ray.is_colliding():
			fling_indicator.global_position = ray.get_collision_point()
			fling_indicator.show()
		else:
			fling_indicator.hide()
	else:
		fling_indicator.global_position = player.grapplepoint
	
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(_event):
	


	if Input.is_action_just_pressed("grapple"):
		ray.force_raycast_update()
		if ray.is_colliding():
			var point = ray.get_collision_point()
			var distance = ray.get_collision_point().distance_to(owner.position)

			player.setgrapple(point, distance)
			

	if Input.is_action_just_released("grapple"):
		player.releasegrapple()
	
	if Input.is_action_just_pressed("grapplefling"):
		player.grapplefling(grapplespeed)

			
			
			
			

	


	
