# rigidbody character controller
extends RigidBody2D

class_name Player

var speed = 320
var max_speed = 3200
var jump_speed = 3200
var base_gravity = 100
var Slope_Threshold = deg_to_rad(50.0)
var base_scale
var grappleForceScalar =  4


var gravity
var on_ground = false
var sliding = false
var slamming
var grapplepoint
var grappledistance
@onready var grappleline:Line2D = $GrappleVis/Line2D
@onready var grappleparticles:GPUParticles2D = $GrappleVis


func _ready():
	base_scale = $Icon.global_scale


	gravity_scale = 0
	gravity = base_gravity
	
func _process(_delta):
	if sliding:
		$Icon.global_scale.y = base_scale.y*0.9
		$Icon.global_scale.x = base_scale.x*1.1
		$Icon.position.y = 1
		
		
	else:
		$Icon.global_scale.y = base_scale.y
		$Icon.global_scale.x = base_scale.x
		$Icon.position.y = 0
		
	queue_redraw()
	#put line between player and grapple point
	if grapplepoint != null:
		grappleline.points = [Vector2.ZERO, grapplepoint - global_position]
		grappleline.visible = true
	else:
		grappleline.visible = false
	#put particles along line
	if grapplepoint != null:
		grappleparticles.emitting = true
		grappleparticles.process_material.direction = Vector3((grapplepoint - global_position).normalized().x, (grapplepoint - global_position).normalized().y, 0)
		grappleparticles.process_material.spread =10
		
	else:
		grappleparticles.emitting = false
		
	
	
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

	if grapplepoint == null:
		if Input.is_action_pressed("move_right"):
			motion.x += 1
		if Input.is_action_pressed("move_left"):
			motion.x -= 1
		
	
	# move along the slope if on a slope
	if on_ground and collision.get_angle() != 0:
		# rotate the motion vector to the normal of the slope using the collision normal
		if grapplepoint == null:
			motion = motion.rotated(collision.get_normal().angle() + PI/2)
		
		
	

		
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

	apply_central_impulse(Vector2(0, motion.y))

	
	# if linear_velocity.x is greater than max_speed and in the direction of motion.x dont add motion.x
	if (abs(linear_velocity.x) < max_speed or sign(linear_velocity.x) != sign(motion.x)) and not sliding and not slamming:
		apply_central_impulse(Vector2(motion.x, 0))
	
		
	#move camera ahead of player based on velocity and motion and mouse position
	var camera_offset = Vector2.ZERO
	camera_offset = camera_offset.lerp(get_local_mouse_position()-camera_offset*100, .2)
	if abs(linear_velocity.x) > 100:
		camera_offset.x += linear_velocity.x * 0.0001
		camera_offset.y += linear_velocity.y * 0.0001
	$Camera2D.position = lerp($Camera2D.position, Vector2.ZERO + camera_offset, .1)
	
		

	# zoom camera vector based on velocity
	if abs(linear_velocity.x) > 100:
		$Camera2D.zoom.x = max(lerp($Camera2D.zoom.x, 0.8 - abs(linear_velocity.x)*0.000001, .1), 0.025)
		$Camera2D.zoom.y = max(lerp($Camera2D.zoom.y, 0.8 - abs(linear_velocity.x)*0.000001, .1), 0.025)
	else:
		$Camera2D.zoom.x = lerp($Camera2D.zoom.x, 1.0, .1)
		$Camera2D.zoom.y = lerp($Camera2D.zoom.y, 1.0, .1)

	
func _integrate_forces(state):
	# prevent slipping down slopes while standing still but allow sliding

	var collision = KinematicCollision2D.new()

	if on_ground and not sliding:
		state.linear_velocity.x = lerp(linear_velocity.x,0.0, 0.1)
		state.linear_velocity.y = lerp(linear_velocity.y,0.0, 0.1)

	# grapple logic
	if grappledistance != null and grapplepoint != null:
		# dont allow player to leave grapple radius
		if global_position.distance_to(grapplepoint) > grappledistance:
			apply_central_impulse((grapplepoint - global_position).normalized() * ((grapplepoint - global_position).length() - grappledistance)*grappleForceScalar)
			
				
		if state.linear_velocity.dot(grapplepoint - global_position) < 0 and global_position.distance_to(grapplepoint) >= grappledistance:
			#cancel any velocity in the opposite direction of the grapple point
			var projectionvec = (state.linear_velocity.project((grapplepoint - global_position).rotated(PI/2)))
			state.linear_velocity = projectionvec.normalized() * state.linear_velocity.length()

		if global_position.distance_to(grapplepoint) < grappledistance * 0.9:
			grappledistance -= 5
		
			


	if test_move(transform, Vector2(0, 1), collision) and not sliding and abs(collision.get_angle()) > 0:
		gravity = 0
		#apply force to push player onto slope using the collision normal
		apply_central_force (collision.get_normal() * -10000)
		
	else:
		gravity = base_gravity	


func setgrapple(point:Vector2, distance:float = -1):
	grapplepoint = point
	if distance != -1:
		grappledistance = distance
	else:
		grappledistance = global_position.distance_to(grapplepoint)

func releasegrapple():
	grapplepoint = null
	grappledistance = null

func grapplefling(flingspeed:float):
	if grapplepoint != null:
		apply_central_impulse((grapplepoint - global_position).normalized() * flingspeed)
		releasegrapple()
	

func _draw():
	if false:
		draw_line(Vector2.ZERO, grapplepoint - global_position, Color(1, 1, 1, 1), 2)
		draw_circle(grapplepoint - global_position, 5, Color(1, 1, 1, 1))
		draw_circle(grapplepoint - global_position, grappledistance, Color(1, 1, 1, 0.1))
		#draw velocity vector
		draw_line(Vector2.ZERO, linear_velocity, Color(1, 1, 1, 1), 2)
		#draw rotated velocity vector
		draw_line(Vector2.ZERO, linear_velocity.rotated(grapplepoint.angle_to(global_position) + PI/2), Color(1, 1, 1, 1), 2)
	
