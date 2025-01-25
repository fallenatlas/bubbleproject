class_name RoamEnemy extends Area2D

@export var air_syphoned : float = 10.0
const SPEED = 120.0
var velocity : Vector2 = Vector2(0, 0)
#const JUMP_VELOCITY = -400.0

@onready var detect_raycast : RayCast2D = $Detect
@onready var front_raycast : RayCast2D = $Front
@onready var right_raycast : RayCast2D = $Right
@onready var left_raycast : RayCast2D = $Left

var max_front_angle : float = 20
var max_side_angle : float = 20

var max_side_velocity_difference : float = 2

var side_array = [-1, 0, 1]
var timer = 5.0
var side = 1

var default_look : Vector2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	timer += delta
	var add_velocity : Vector2 = Vector2(0,0)
	
	if front_raycast.is_colliding():
		#check if is player, if so chase
		var object = front_raycast.get_collider()
		var player : CharacterBody2D = object as CharacterBody2D
		if player == null:
			add_velocity += -global_transform.x * 0.01

	if (timer > 2.0):
		side = side_array[randi() % side_array.size()]
		timer = 0.0
	add_velocity += global_transform.x * 5 + 0.001 * global_transform.y * side
	
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
			if !left_raycast.is_colliding() or !front_raycast.is_colliding():
				add_velocity += -global_transform.y * 0.001 * (right_raycast.get_collision_point() - global_position).length()
	
	var ang_diff = velocity.angle_to(add_velocity)
	if abs(ang_diff) > PI/120:
		add_velocity = velocity.normalized().rotated(ang_diff/abs(ang_diff) * PI/120) * add_velocity.length()
	
	velocity = add_velocity * add_velocity.length()/max(add_velocity.length(), 0.1)
	
	self.look_at(global_position + velocity)
	
	position += velocity * delta
	#move_and_slide()


func _on_body_entered(body: Node2D) -> void:
	var player : CharacterBody2D = body as CharacterBody2D

	if player != null:
		print("syphon")
		Events.emit_signal("syphon", air_syphoned)
