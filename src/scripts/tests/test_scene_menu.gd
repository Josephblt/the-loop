extends Control


const SPAWN_ROOM_TEST_SCENE: String = "res://tests/spawn_room_test.tscn"
const DENIAL_ROOM_TEST_SCENE: String = "res://tests/denial_room_test.tscn"
const DEPRESSION_ROOM_TEST_SCENE: String = "res://tests/depression_room_test.tscn"
const MEMORY_ROOM_TEST_SCENE: String = "res://tests/memory_room_test.tscn"

const GAME_SESSION_SEED: int = 0

@export var story: Story


func _open_test_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func _on_spawn_room_pressed() -> void:
	_open_test_scene(SPAWN_ROOM_TEST_SCENE)


func _on_denial_room_button_pressed() -> void:
	_open_test_scene(DENIAL_ROOM_TEST_SCENE)


func _on_depression_room_pressed() -> void:
	_open_test_scene(DEPRESSION_ROOM_TEST_SCENE)


func _on_memory_room_pressed() -> void:
	_open_test_scene(MEMORY_ROOM_TEST_SCENE)
