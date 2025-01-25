extends CharacterBody2D

@export var speed: float
@export var bubble_speed: float
@export var oxygen_rate: float

var oxygen = 100.0

var dead : bool = false

var reset_position : Vector2
var reset_oxygen

func _ready() -> void:
	reset_position = global_position
	reset_oxygen = oxygen
	Events.dead.connect(_on_dead)
	Events.syphon.connect(_on_syphoned)

func reset() -> void:
	global_position = reset_position
	oxygen = reset_oxygen
	dead = false

func _on_dead() -> void:
	dead = true
	velocity = Vector2(0,0)
	
func _on_syphoned(amount : float) -> void:
	oxygen -= amount

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	oxygen -= oxygen_rate
	
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("shoot_bubble"):
		var bubble = preload("res://bubble.tscn").instantiate()
		bubble.translate(position + input * 32)
		bubble.linear_velocity = velocity + input * bubble_speed
		get_tree().root.add_child(bubble)
	
	if input.x != 0 or input.y != 0:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("horizontal", true)
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("horizontal", false)
	
	if input.x != 0:
		$AnimatedSprite2D.flip_h = input.x < 0 or not input.x > 0
	
	velocity = velocity.lerp(input * speed, delta)
	move_and_slide()
