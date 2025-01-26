extends Node2D

var current_zone : int = 0
const MAP_SIZE_Y : int = -368

@export var player : CharacterBody2D
@export var camera : Camera2D

var initial_scene : String = "initial_scene.tscn"
var terrain_scenes : Array = ["a.tscn", "b.tscn", "c.tscn", "d.tscn", "e.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_map()

func start_map() -> void:
	current_zone = 0
	for child in get_children():
		remove_child(child)
		child.call_deferred("free")
		
	var scene = load("res://terrain_scenes/" + initial_scene).instantiate()
	scene.name = str(current_zone)
	add_child(scene)
	
	spawn_zone()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player.global_position.y < MAP_SIZE_Y * (current_zone - 1)):
		spawn_zone()
		delete_zone()
		camera.limit_bottom = MAP_SIZE_Y * (current_zone - 3)

func spawn_zone() -> void:
	current_zone += 1
	var rand_scene : String = terrain_scenes[randi() % terrain_scenes.size()]
	var scene = load("res://terrain_scenes/" + rand_scene).instantiate()
	scene.position.y = MAP_SIZE_Y * current_zone
	scene.name = str(current_zone)
	add_child(scene)

func delete_zone() -> void:
	var scene_to_delete : int = current_zone - 3
	if (scene_to_delete < 0):
		return
	var level = get_node("./" + str(scene_to_delete))
	self.remove_child(level)
	level.call_deferred("free")
