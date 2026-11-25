class_name MemoryRoom
extends Node3D


signal chest_opened(chest_index: int)


@export var chest: Chest
@export var fire_fixtures: Array[FireFixture] = []

var _chest_index: int


func setup_room(session_seed: int, chest_index: int) -> void:
	_chest_index = chest_index
	SceneRandomizer.randomize_scene(self, session_seed)


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	chest_opened.emit(_chest_index)
