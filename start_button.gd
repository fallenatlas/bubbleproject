extends Button

@export var camera : Camera2D

func _on_pressed() -> void:
	get_parent().hide()
	camera.unlock()
	#hide start menu
	#send event for camera
