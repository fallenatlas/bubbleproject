extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	var enemy : CharacterBody2D = body as CharacterBody2D
	if (enemy != null):
		Events.emit_signal("enemy_kill")
	queue_free()
