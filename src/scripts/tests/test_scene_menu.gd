extends Control


const SPAWN_ROOM_TEST_SCENE: String = "res://tests/spawn_room_test.tscn"
const DEPRESSION_ROOM_TEST_SCENE: String = "res://tests/depression_room_test.tscn"
const MEMORY_ROOM_TEST_SCENE: String = "res://tests/memory_room_test.tscn"
const GAME_SESSION_SEED: int = 0


func _open_test_scene(scene_path: String) -> void:
	var error: Error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to open test scene '%s': %s" % [scene_path, error_string(error)])


func _on_spawn_room_pressed() -> void:
	_open_test_scene(SPAWN_ROOM_TEST_SCENE)


func _on_depression_room_pressed() -> void:
	_open_test_scene(DEPRESSION_ROOM_TEST_SCENE)


func _on_memory_room_pressed() -> void:
	_open_test_scene(MEMORY_ROOM_TEST_SCENE)


func _on_game_session_pressed() -> void:
	GameSession.create(
		GAME_SESSION_SEED,
		GriefStagesStack.new(GAME_SESSION_SEED),
		MemoriesStack.new(GAME_SESSION_SEED),
		0
	)
