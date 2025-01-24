extends CharacterBody2D

@export var speed = 300

func _physics_process(delta: float) -> void:
	velocity = velocity.lerp(Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed, delta)
	$Sprite2D.rotation = get_global_mouse_position().angle_to_point(position)
	
	if get_viewport().get_mouse_position().x < position.x:
		$Sprite2D.flip_v = false
	else:
		$Sprite2D.flip_v = true
	
	move_and_slide()
