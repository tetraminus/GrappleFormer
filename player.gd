# rigidbody character controller
extends RigidBody2D

var speed = 160
var max_speed = 1600
var jump_speed = 1600
var base_gravity = 80
var Slope_Threshold = deg_to_rad(50.0)
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
		
var coyote_timer = 0

#2d rigidbody character controller
func _physics_process(_delta):
	
	
	var collision = KinematicCollision2D.new()
	if test_move(transform, Vector2(0, 1), collision) and collision.get_angle() < Slope_Threshold:
		on_ground = true
		coyote_timer = 0
	else:
		coyote_timer += _delta
		if coyote_timer > 0.1:
			on_ground = false
			coyote_timer = 0
		

	var motion = Vector2()

	if Input.is_action_pressed("move_right"):
		motion.x += 1
	if Input.is_action_pressed("move_left"):
		motion.x -= 1
		
	
	# move along the slope if on a slope
	# move along the slope if on a slope
	if on_ground and collision.get_angle() != 0:
		# rotate the motion vector to the normal of the slope using the collision normal
		motion =  motion.rotated(collision.get_normal().angle() + PI/2)

		

		


		
		
	if Input.is_action_just_pressed("move_down") and not slamming:
		motion.y += 1
		linear_velocity.x *= 0.4
		if linear_velocity.y < 0:
			linear_velocity.y *= 0.4
		gravity = base_gravity * 8
		slamming = true

	if not Input.is_action_pressed("move_down") and on_ground:
		if sliding:
			sliding = false
			


	
	if on_ground:
		if slamming:
			slamming = false
			gravity = base_gravity
			sliding = true

	

	motion = motion.normalized()

	motion = motion * speed

	if on_ground and Input.is_action_pressed("jump"):
		on_ground = false
		#if sliding on a slope jump away from the slope
		if sliding:
			motion.y = -jump_speed*1.5
			motion.x = -sign(motion.x)*jump_speed*1.5
		else:
			motion.y = -jump_speed
		
		
		


	
	motion.y += gravity

	linear_velocity.y += motion.y
	
	# if linear_velocity.x is greater than max_speed and in the direction of motion.x dont add motion.x
	if (abs(linear_velocity.x) < max_speed or sign(linear_velocity.x) != sign(motion.x)) and not sliding and not slamming:
		linear_velocity.x += motion.x
	
	
	
	if on_ground and not sliding:
		linear_velocity.x = lerp(linear_velocity.x,0.0, 0.1)
		linear_velocity.y = lerp(linear_velocity.y,0.0, 0.1)
		
	#move camera ahead of player based on velocity and motion
	$Camera2D.global_position.x = lerp($Camera2D.global_position.x, global_position.x + motion.x*.25 , .01)
	$Camera2D.global_position.x = lerp($Camera2D.global_position.x, global_position.x + linear_velocity.x*.025 , .1)
	# zoom camera vector based on velocity
	if abs(linear_velocity.x) > 100:
		$Camera2D.zoom.x = max(lerp($Camera2D.zoom.x, 0.125 - abs(linear_velocity.x)*0.00001, .1), 0.025)
		$Camera2D.zoom.y = max(lerp($Camera2D.zoom.y, 0.125 - abs(linear_velocity.x)*0.00001, .1), 0.025)
	
	
func _integrate_forces(state):
	# prevent slipping down slopes while standing still but allow sliding

	var collision = KinematicCollision2D.new()

	if test_move(transform, Vector2(0, 1), collision) and not sliding and abs(collision.get_angle()) > 0:
		gravity = 0
		#push player onto slope
		
	else:
		gravity = base_gravity
		
		
		




	


	
	
	


