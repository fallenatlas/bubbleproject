extends Camera2D

@export var player : CharacterBody2D
var locked : bool = true
var speed : float = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = player.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (locked):
		return
	global_position = global_position.lerp(player.global_position, speed * delta)

func unlock() -> void:
	locked = false
