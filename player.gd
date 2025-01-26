extends CharacterBody2D

@export var speed: float
@export var bubble_speed: float
@export var oxygen_rate: float

var oxygen = 100.0
var direction = Vector2.RIGHT

var dead : bool = false
var healing : bool = false

var reset_position : Vector2
var reset_oxygen

func _ready() -> void:
	reset_position = global_position
	reset_oxygen = oxygen
	Events.dead.connect(_on_dead)
	Events.syphon.connect(_on_syphoned)
	Events.air_entered.connect(_on_air_entered)
	Events.air_exited.connect(_on_air_exited)

func reset() -> void:
	global_position = reset_position
	oxygen = reset_oxygen
	dead = false

func _on_air_entered() -> void:
	oxygen = 100.0
	healing = true

func _on_air_exited() -> void:
	healing = false

func _on_dead() -> void:
	dead = true
	velocity = Vector2(0,0)
	
func _on_syphoned(amount : float) -> void:
	oxygen -= amount

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	if not healing:
		oxygen -= oxygen_rate
	print(oxygen)
	
	if oxygen <= 0:
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
		Vector2.RIGHT:
			$AnimationPlayer.play("horizontal")
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.flip_v = false
		Vector2.UP:
			$AnimationPlayer.play("vertical")
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.flip_v = false
		Vector2.DOWN:
			$AnimationPlayer.play("vertical")
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.flip_v = true
		_:
			if direction.x > 0 and direction.y < 0:
				$AnimationPlayer.play("diagonal_ur")
			elif direction.x < 0 and direction.y < 0:
				$AnimationPlayer.play("diagonal_ul")
			elif direction.x > 0 and direction.y > 0:
				$AnimationPlayer.play("diagonal_dr")
			elif direction.x < 0 and direction.y > 0:
				$AnimationPlayer.play("diagonal_dl")
	
	velocity = velocity.lerp(input * speed, delta)
	move_and_slide()
