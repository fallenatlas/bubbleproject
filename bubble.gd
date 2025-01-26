extends RigidBody2D

func _on_enemy_killed():
	$AudioStreamPlayer2D.play()
	set_deferred("freeze", true)
	$AnimatedSprite2D.play()
	await get_tree().create_timer(0.4).timeout
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.enemy_killed.connect(_on_enemy_killed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	var enemy : CharacterBody2D = body as CharacterBody2D
	if (enemy != null):
		Events.emit_signal("enemy_kill")
	
	$AudioStreamPlayer2D.play()
	set_deferred("freeze", true)
	get_node("CollisionShape2D").set_deferred("disabled", true)
	$AnimatedSprite2D.play()
	await get_tree().create_timer(0.4).timeout
	queue_free()
	
