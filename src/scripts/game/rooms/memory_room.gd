class_name MemoryRoom
extends Node3D


signal chest_opened()


@export var chest: Chest
@export var fire_fixtures: Array[FireFixture] = []


func setup_room(session_seed: int) -> void:
	SceneRandomizer.randomize_scene(self, session_seed)


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	chest_opened.emit(chest)
