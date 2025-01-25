extends Control

@export var start_menu : Control
@export var dead_menu : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_cancel")):
		if (start_menu.visible or dead_menu.visible):
			return
		if (self.visible):
			self.hide()
		else:
			self.show()
		get_tree().paused = !get_tree().paused


func _on_continue_pressed() -> void:
	self.hide()
	get_tree().paused = false
