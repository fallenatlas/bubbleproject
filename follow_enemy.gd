class_name FollowEnemy extends CharacterBody2D

const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

#keep player here when found and while in range
var chase_player : CharacterBody2D = null

@onready var detect_raycast : RayCast2D = $Detect
@onready var front_raycast : RayCast2D = $Front
@onready var right_raycast : RayCast2D = $Right
@onready var left_raycast : RayCast2D = $Left

var max_front_angle : float = 20
var max_side_angle : float = 20

var max_side_velocity_difference : float = 2

var player_predict : float = 0.1

var side_array = [-1, 0, 1]
var timer = 5.0
var side = 1

var look_timer = 0.5
var default_look : Vector2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	timer += delta
	look_timer += delta
	var add_velocity : Vector2 = Vector2(0,0)
	
	# if player is not null chase
	if (chase_player != null):
		if (chase_player.global_position - self.global_position).length() > 15:
			chase_player = null
	
	# check all 3 raycasts
	if front_raycast.is_colliding():
		#check if is player, if so chase
		var object = front_raycast.get_collider()
		var player : CharacterBody2D = object as CharacterBody2D
		if player != null:
			chase_player = player
		else:
			# deviate from wall
			add_velocity += -global_transform.x * 0.01
	
	# if player is not null chase
	if chase_player != null:
		add_velocity += (chase_player.global_position - self.global_position) * 15 #+ (player_predict * chase_player.velocity)
	else:
		# kinda make this random
		if (timer > 2.0):
			side = side_array[randi() % side_array.size()]
			timer = 0.0
		add_velocity += global_transform.x * 10 + 0.01 * global_transform.y * side
	
	# if wall, go away from them
	if left_raycast.is_colliding():
		var object = left_raycast.get_collider()
		var player : CharacterBody2D = object as CharacterBody2D
		if player == null:
			add_velocity += global_transform.y * 0.001 * (left_raycast.get_collision_point() - global_position).length()
	
	if right_raycast.is_colliding():
		var object = front_raycast.get_collider()
		var player : CharacterBody2D = object as CharacterBody2D
		if player == null:
			add_velocity += -global_transform.y * 0.001 * (right_raycast.get_collision_point() - global_position).length()
	
	# change the angle on the raycast
	if look_timer > 0.5:
		detect_raycast.rotation_degrees = -90 + randf_range(-15, 15)
		look_timer = 0.0
	
	velocity = add_velocity
	
	self.look_at(global_position + velocity)
	
	move_and_slide()
