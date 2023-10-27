# rigidbody character controller
extends RigidBody2D

class_name Player

@export var speed = 320
@export var max_speed = 3200
@export var jump_speed = 3200
@export var base_gravity = 100
@export var Slope_Threshold_Degrees = 50.0
var Slope_Threshold = deg_to_rad(Slope_Threshold_Degrees)
var base_scale
@export var grappleForceScalar =  4
@onready var animation = $AnimationPlayer

@onready var launch_cooldown = $LaunchCooldown
@onready var fling_indicator = $flingIndicator
var dead = false

var current_spawnpoint

var gravity
var on_ground = false
var sliding = false
var slamming
var grapplepoint
var grappledistance
@onready var grappleline:Line2D = $GrappleVis/Line2D
@onready var grappleparticles:GPUParticles2D = $GrappleVis
var flinging
var variable_jump = 0
var idlePlaying = true
var doubleIdleSpecial = true
var launchRefreshed = true

func _ready():
	base_scale = $Icon.global_scale
	flinging = false

	gravity_scale = 0
	gravity = base_gravity
	launch_cooldown.timeout.connect(_launchReady)
	animation.animation_finished.connect(_on_anim_ended)

	
func SetSpawnpoint(spawnpoint:Node2D) -> void:
	current_spawnpoint = spawnpoint


func _launchReady():
	
	launchRefreshed = true
	fling_indicator.emitting = true

func _on_anim_ended(_anim):
	if idlePlaying == true:
		
		if randi_range(1,10) == 5 and doubleIdleSpecial == false:
		
			animation.play("idle 2")
			doubleIdleSpecial = true
			
		elif randi_range(1,10) == 5 and doubleIdleSpecial == false:
			
			animation.play("idle 3")
			doubleIdleSpecial = true
			
		else:
			
			animation.play("idle 1")
			doubleIdleSpecial = false
	
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
		
		if grapplepoint.x - global_position.x != 0 and linear_velocity.y != 0 and not on_ground:
			$Icon.rotation = atan(((grapplepoint.y - global_position.y)) / ((grapplepoint.x - global_position.x))) +  (sign(grapplepoint.x - global_position.x) * 3.1415/2)
			animation.play("grapple")
		
		elif on_ground:
			$Icon.rotation = 0
			animation.play("grappleStart")
		
		grappleparticles.emitting = true
		grappleparticles.process_material.direction = Vector3((grapplepoint - global_position).normalized().x, (grapplepoint - global_position).normalized().y, 0)
		grappleparticles.process_material.spread =10
		
	else:
		grappleparticles.emitting = false
		$Icon.rotation = 0
		
		
	if get_colliding_bodies().size() > 0:
		launch_cooldown.stop()
		launchRefreshed = true
		fling_indicator.emitting = true
		
var coyote_timer = 0
var testvec
#2d rigidbody character controller
func _physics_process(_delta):
	
	
	var collision = KinematicCollision2D.new()
	if test_move(transform, Vector2(0, .1), collision) and collision.get_angle() < Slope_Threshold:
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
			$Icon.flip_h = false
		if Input.is_action_pressed("move_left"):
			motion.x -= 1
			$Icon.flip_h = true
			
	
		
	
	# move along the slope if on a slope
	if on_ground and collision.get_angle() != 0:
		# rotate the motion vector to the normal of the slope using the collision normal
		#print(collision.get_angle())

		if grapplepoint == null:
			#motion = motion.rotated(clamp(collision.get_normal().angle() + PI/2, -Slope_Threshold, Slope_Threshold))
			pass
		
		
	testvec=motion
		
	if linear_velocity.length() < 5:
		
		if idlePlaying == false:
			animation.stop()
			animation.play("idle 1")
		
		idlePlaying = true
		
		
	elif on_ground:
		
		animation.play("walk")

				
		
	else:
		idlePlaying = false
		
		

		
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
		variable_jump = 9
		#if sliding on a slope jump away from the slope
		if sliding:
			motion.y = -jump_speed*1.5
			motion.x = -sign(motion.x)*jump_speed*1.5
		
	
	if Input.is_action_pressed("jump") and sliding == false and variable_jump != 0:
		motion.y -= (jump_speed * variable_jump) / 40
		variable_jump -= 1
		
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
	
func _integrate_forces(state):
	# prevent slipping down slopes while standing still but allow sliding

	var collision = KinematicCollision2D.new()

	#TODO
	if on_ground:
		if  not sliding:
			state.linear_velocity.x = lerp(linear_velocity.x,0.0, 0.3)
			state.linear_velocity.y = lerp(linear_velocity.y,0.0, 0.1)
		else: 
			state.linear_velocity.x = lerp(linear_velocity.x,0.0, 0.05)
			
	elif abs(linear_velocity.x) > 1 and grappledistance == null:
		state.linear_velocity.x = lerp(linear_velocity.x,0.0, 1/abs(linear_velocity.x * linear_velocity.x * linear_velocity.x))
	
	elif grappledistance == null:
		state.linear_velocity.x = lerp(linear_velocity.x,0.0, 1)
	
	if grapplepoint == null or not on_ground:
		
		
		if linear_velocity.x > 1:
			$Icon.flip_h = false
		
		elif linear_velocity.x < -1:
			$Icon.flip_h = true
				
			
	# grapple logic
	if grappledistance != null and grapplepoint != null:
		# dont allow player to leave grapple radius
		if global_position.distance_to(grapplepoint) > grappledistance:
			apply_central_impulse((grapplepoint - global_position).normalized() * ((grapplepoint - global_position).length() - grappledistance)*grappleForceScalar)
			
				
		if state.linear_velocity.dot(grapplepoint - global_position) < 0 and global_position.distance_to(grapplepoint) >= grappledistance:
			#cancel any velocity in the opposite direction of the grapple point
			var projectionvec = (state.linear_velocity.project((grapplepoint - global_position).rotated(PI/2)))
			state.linear_velocity = projectionvec.normalized() * state.linear_velocity.length()
		
	
			#THIS SHOULD FLIP THE PLAYER TO POINT TOWARDS THE CURSOR
			

		if global_position.distance_to(grapplepoint) < grappledistance * 0.9:
			grappledistance -= 5
		
			

	if test_move(transform, Vector2(0, .1), collision) and not sliding and not flinging:
		gravity = 0
		#apply force to push player onto slope using the collision normal
		apply_central_force (collision.get_normal() * -10)
		
		
	else:
		gravity = base_gravity	
		if flinging:
			flinging

func setgrapple(point:Vector2, distance:float = -1)-> void:
	grapplepoint = point
	
	if distance != -1:
		grappledistance = distance
	else:
		grappledistance = global_position.distance_to(grapplepoint)

func releasegrapple()-> void:
	grapplepoint = null
	grappledistance = null

func grapplefling(flingspeed:float)-> void:
	if grapplepoint != null and launchRefreshed:
		
		linear_velocity.x /= 2
		linear_velocity.y = 0
		apply_central_impulse((grapplepoint - global_position).normalized() * flingspeed)
		releasegrapple()
		

		launch_cooldown.start()
		launchRefreshed = false
		fling_indicator.emitting = false
		fling_indicator.lifetime = 0.1
		
func _draw()-> void:
	
	#draw_line(Vector2.ZERO, testvec *50, Color(1, 1, 1, 1), 2)
		
		
	pass

func die() -> void:
	print("player died")
	set_physics_process(false)
	var zoopTween = get_tree().create_tween()
	grappledistance = null
	grapplepoint = null
	dead = true

	zoopTween.tween_property(self,"global_position", current_spawnpoint.global_position,.3)
	await zoopTween.finished
	linear_velocity = Vector2.ZERO
	set_physics_process(true)
	dead = false
	



