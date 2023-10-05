# rigidbody character controller
extends RigidBody2D

var speed = 40
var max_speed = 400
var jump_speed = 400
var base_gravity = 20
var Slope_Threshold = deg_to_rad(45.0)
var base_scale


var gravity
var on_ground = false
var sliding = false
var slamming


func _ready():
	base_scale = $Icon.global_scale


	gravity_scale = 0
	gravity = base_gravity
	
func _process(delta):
	if sliding:
		$Icon.global_scale.y = base_scale.y*0.9
		$Icon.global_scale.x = base_scale.x*1.1
		$Icon.position.y = 1
		
		
	else:
		$Icon.global_scale.y = base_scale.y
		$Icon.global_scale.x = base_scale.x
		$Icon.position.y = 0
		
	

#2d rigidbody character controller
func _physics_process(_delta):
	
	
	var collision = KinematicCollision2D.new()
	if test_move(transform, Vector2(0, 4), collision) and collision.get_angle() < Slope_Threshold:
		on_ground = true
	else:
		on_ground = false

	var motion = Vector2()

	if Input.is_action_pressed("ui_right"):
		motion.x += 1
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1

	# move along the slope if on a slope
	if on_ground and collision.get_angle() > 0:
		# rotate the motion vector to the angle of the slope
		motion = motion.rotated(collision.get_angle())

		
		
	if Input.is_action_just_pressed("ui_down") and not slamming:
		motion.y += 1
		gravity = base_gravity * 2
		slamming = true

	if not Input.is_action_pressed("ui_down") and on_ground:
		if sliding:
			sliding = false
			


	
	if on_ground:
		if slamming:
			slamming = false
			gravity = base_gravity
			sliding = true

	

	motion = motion.normalized()

	motion = motion * speed

	if on_ground and Input.is_action_pressed("ui_up"):
		motion.y = -jump_speed


	
	motion.y += gravity

	linear_velocity.y += motion.y
	
	# if linear_velocity.x is greater than max_speed and in the direction of motion.x dont add motion.x
	if (abs(linear_velocity.x) < max_speed or sign(linear_velocity.x) != sign(motion.x)) and not sliding :
		linear_velocity.x += motion.x
	
	
	
	if on_ground and not sliding:
		linear_velocity.x = lerp(linear_velocity.x,0.0, 0.1)
		
	#move camera ahead of player based on velocity
	$Camera2D.global_position.x = lerp($Camera2D.global_position.x, global_position.x + linear_velocity.x*0.01, 1)
	# zoom camera vector based on velocity
	$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1 - abs(linear_velocity.x)*0.001, .1)
	$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 1 - abs(linear_velocity.x)*0.001, .1)
	
	
func _integrate_forces(state):
	# prevent slipping down slopes while standing still but allow sliding

	var collision = KinematicCollision2D.new()

	if test_move(transform, Vector2(0, 4), collision) and not sliding and collision.get_angle() > 0:
		gravity = 0
		#push player into slope
		var push = Vector2()
		push = collision.get_normal() * -1
		push = push * 100
		apply_central_force(push)
		
	else:
		gravity = base_gravity
		
		
		




	


	
	
	


