extends Node2D
@onready var grappleRay: RayCast2D = $GrappleRay
@onready var blocker_ray = $BlockerRay
@export var grappledistance:int
@export var grapplespeed:int
var player
@onready var fling_indicator = %flingIndicator
var fling_pos = null


# Called when the node enters the scene tree for the first time.
func _ready():
	grappleRay.target_position = Vector2(grappledistance,0)
	blocker_ray.target_position = Vector2(grappledistance,0)
	player = owner as Player
	#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED)
	

func _process(_delta):

	
	if player.grapplepoint == null:
		if fling_pos != null:
			fling_indicator.visible = true
			fling_indicator.global_position = fling_indicator.global_position.lerp(fling_pos, 0.5)
		else:
			fling_indicator.visible = false
	else:
		fling_indicator.global_position = player.grapplepoint
		

func _physics_process(_delta):
	look_at(get_global_mouse_position())
	var blockerpos = blocker_ray.get_collision_point()

	if blocker_ray.get_collider() != null:
		grappleRay.target_position = Vector2(blocker_ray.global_position.distance_to(blockerpos),0)
		grappleRay.force_raycast_update()
	else :
		grappleRay.target_position = Vector2(grappledistance,0)
		grappleRay.force_raycast_update()

	var grapplepos = grappleRay.get_collision_point()

	if grapplepos != null:
		fling_pos = grapplepos
	

	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(_event):
	

	if Input.is_action_just_pressed("grapple"):
		grappleRay.force_raycast_update()
		
		if fling_pos != null:
			var point = fling_pos

			var distance = fling_pos.distance_to(owner.position)
				
			if distance < grappledistance:
				player.setgrapple(point, distance)
			
			
			
			
			

	if Input.is_action_just_released("grapple"):
		player.releasegrapple()
	
	if Input.is_action_just_pressed("grapplefling"):
		player.grapplefling(grapplespeed)

			
			
			
			

	


	
