class_name FollowEnemy extends CharacterBody2D

const SPEED = 120.0
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

var dead = false

var look_timer = 0.5
var default_look : Vector2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not dead:
		timer += delta
		look_timer += delta
		var add_velocity : Vector2 = Vector2(0,0)
		
		# if player is not null chase
		if (chase_player != null):
			if (chase_player.global_position - self.global_position).length() > 200:
				chase_player = null
		
		# check all 3 raycasts
		if detect_raycast.is_colliding():
			#check if is player, if so chase
			var object = detect_raycast.get_collider()
			var player : CharacterBody2D = object as CharacterBody2D
			if player != null:
				chase_player = player
		
		if front_raycast.is_colliding():
			#check if is player, if so chase
			var object = front_raycast.get_collider()
			var player : CharacterBody2D = object as CharacterBody2D
			if player == null:
				add_velocity += -global_transform.x * 0.01
		
		# if player is not null chase
		if chase_player != null:
			#var change = (chase_player.global_position - self.global_position)
			add_velocity += (chase_player.global_position - self.global_position).normalized() * SPEED# + 0.5 * (player_predict * chase_player.velocity)
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
				if !left_raycast.is_colliding() or !front_raycast.is_colliding():
					add_velocity += -global_transform.y * 0.001 * (right_raycast.get_collision_point() - global_position).length()
		
		# change the angle on the raycast
		if look_timer > 0.5:
			detect_raycast.rotation_degrees = -90 + randf_range(-20, 20)
			look_timer = 0.0
		
		var ang_diff = velocity.angle_to(add_velocity)
		if abs(ang_diff) > PI/120:
			add_velocity = velocity.normalized().rotated(ang_diff/abs(ang_diff) * PI/120) * add_velocity.length()
		
		velocity = add_velocity * add_velocity.length()/max(add_velocity.length(), 0.1)
		
		self.look_at(global_position + velocity)
		
		if -135 < rotation_degrees and rotation_degrees < -45:
			$AnimatedSprite2D.play("up")
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.rotation_degrees = 90
		elif -45 < rotation_degrees and rotation_degrees < 45:
			if chase_player != null:
				$AnimatedSprite2D.play("attack")
			else:
				$AnimatedSprite2D.play("horizontal")
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.rotation_degrees = 0
		elif 45 < rotation_degrees and rotation_degrees < 135:
			$AnimatedSprite2D.play("down")
			$AnimatedSprite2D.flip_v = true
			$AnimatedSprite2D.rotation_degrees = 90
		else:
			if chase_player != null:
				$AnimatedSprite2D.play("attack")
			else:
				$AnimatedSprite2D.play("horizontal")
			$AnimatedSprite2D.flip_v = true
			$AnimatedSprite2D.rotation_degrees = 0

		#position += velocity * delta
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	var player : CharacterBody2D = body as CharacterBody2D
	var bubble = body as RigidBody2D

	if player != null:
		if not dead:
			print("kill")
			Events.emit_signal("dead")
	elif bubble != null:
		dead = true
		Events.emit_signal("enemy_killed")
		get_node("CollisionShape2D").set_deferred("disabled", true)
		get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
		$AnimationPlayer.play("death")
		await get_tree().create_timer(1.0).timeout
		queue_free()
