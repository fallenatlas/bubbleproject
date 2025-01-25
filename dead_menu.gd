extends Control

@export var heightText : RichTextLabel
@export var killsText : RichTextLabel
@export var terrain_manager : Node2D
@export var player : CharacterBody2D
@export var camera : Camera2D

var kill_count : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.enemy_kill.connect(_on_enemy_kill)
	Events.dead.connect(_on_player_dead)

func _on_enemy_kill() -> void:
	kill_count += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_player_dead() -> void:
	heightText.text = str(abs(int(player.global_position.y)))
	killsText.text = str(kill_count)
	self.show()

func _on_restart_pressed() -> void:
	#animation.start
	self.hide()
	#when end:
	terrain_manager.start_map()
	player.reset()
	camera.limit_bottom = 352
	#animation.start
	kill_count = 0
	
	
