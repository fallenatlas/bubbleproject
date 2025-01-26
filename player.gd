extends CharacterBody2D

@export var speed: float
@export var bubble_speed: float
@export var oxygen_rate: float

var oxygen = 100.0
var no_oxygen_timer = 3.0
var direction = Vector2.RIGHT

var dead : bool = false
var healing : bool = true

var shader_alpha : float = 0.0
var shader_way : float = 1

var reset_position : Vector2
var reset_oxygen

var bubble_offset : Vector2 = Vector2(0, 0)

func _ready() -> void:
	reset_position = global_position
	reset_oxygen = oxygen
	Events.dead.connect(_on_dead)
	Events.syphon.connect(_on_syphoned)
	Events.air_entered.connect(_on_air_entered)
	Events.air_exited.connect(_on_air_exited)
	Events.start.connect(_on_start)

func reset() -> void:
	global_position = reset_position
	oxygen = reset_oxygen
	dead = false
	no_oxygen_timer = 3.0

func _on_air_entered() -> void:
	oxygen = 100.0
	healing = true
	no_oxygen_timer = 3.0

func _on_air_exited() -> void:
	healing = false

func _on_dead() -> void:
	dead = true
	velocity = Vector2(0,0)
	
func _on_syphoned(amount : float) -> void:
	oxygen -= amount

func _on_start() -> void:
	healing = false

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	if not healing:
		oxygen -= oxygen_rate
	print(oxygen)
	
	if oxygen <= 0:
		no_oxygen_timer -= delta
		if no_oxygen_timer <= 0:
			Events.emit_signal("dead")
	
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length() != 0:
		direction = input
	
	if Input.is_action_just_pressed("shoot_bubble"):
		oxygen -= 10.0
		var bubble = preload("res://bubble.tscn").instantiate()
		bubble.translate(position + direction * 32)
		bubble.linear_velocity = velocity + direction * bubble_speed
		get_tree().root.add_child(bubble)
	
	match direction:
		Vector2.LEFT:
			$AnimationPlayer.play("horizontal")
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.flip_v = false
			bubble_offset = Vector2(-1, 0)
		Vector2.RIGHT:
			$AnimationPlayer.play("horizontal")
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.flip_v = false
			bubble_offset = Vector2(1, 0)
		Vector2.UP:
			$AnimationPlayer.play("vertical")
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.flip_v = false
			bubble_offset = Vector2(0, -1)
		Vector2.DOWN:
			$AnimationPlayer.play("vertical")
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.flip_v = true
			bubble_offset = Vector2(0, 1)
		_:
			if direction.x > 0 and direction.y < 0:
				$AnimationPlayer.play("diagonal_ur")
				bubble_offset = Vector2(1, -1)
			elif direction.x < 0 and direction.y < 0:
				$AnimationPlayer.play("diagonal_ul")
				bubble_offset = Vector2(-1, -1)
			elif direction.x > 0 and direction.y > 0:
				$AnimationPlayer.play("diagonal_dr")
				bubble_offset = Vector2(1, 1)
			elif direction.x < 0 and direction.y > 0:
				$AnimationPlayer.play("diagonal_dl")
				bubble_offset = Vector2(-1, 1)
	
	velocity = velocity.lerp(input * speed, delta)
	move_and_slide()

func get_shader_alpha(delta : float) -> float:
	if oxygen > 0:
		shader_alpha = 0.0
		return 0.0
	
	if dead:
		return 1.0
	
	if (shader_alpha >= 1):
		shader_way = -1
	elif (shader_alpha <= 0):
		shader_way = 1
		
	shader_alpha += delta * shader_way
	return shader_alpha


func _on_timer_timeout() -> void:
	#instance bubble scene
	if (healing or dead):
		return
	
	var bubble = preload("res://air_bubble.tscn").instantiate()
	bubble.global_position = global_position + bubble_offset * 15 + (global_transform.x * randf_range(-5, 5))
	get_tree().root.add_child(bubble)
