extends AnimatedSprite2D

var time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("up")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += Vector2(0, -1) * 20 * delta
	
	time += delta
	if (time > 3):
		play("default")
		if self.animation_finished:
			queue_free()
