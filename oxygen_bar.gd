extends TextureProgressBar

@export var player : CharacterBody2D

const max_time_alternate : float = 0.2
var time_alternate : float = max_time_alternate
var alternate_on : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = player.oxygen
	Events.syphon.connect(_on_syphoned)

func _on_syphoned(amount : float) -> void:
	texture_progress = load("res://alternate_oxygen_bar.tres")
	alternate_on = true
	time_alternate = max_time_alternate
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if alternate_on:
		time_alternate -= delta
		if time_alternate <= 0:
			texture_progress = load("res://oxygen_bar.tres")
			alternate_on = false
		
	global_position = global_position.lerp(player.global_position, delta * 8)
	value = player.oxygen
