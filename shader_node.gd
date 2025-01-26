extends ColorRect

@export var player : CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var material = self.get_material()
	material.set_shader_parameter("alpha", player.get_shader_alpha(delta))
