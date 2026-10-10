# class_name GameManager
extends Node


const SAVE_FILE_PATH = "user://the_loop_save_game.dat"

var current_game_session: GameSession


func _has_saved_game_session() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)


func save_game(game_session: GameSession):
	var game_session_data: Dictionary = GameSession.serialize(game_session)
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(game_session_data)
	file.close()


func load_game():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var game_session_data: Dictionary = file.get_var()
	file.close()

	start_game(game_session_data)


func start_game(game_session_data: Dictionary = {}):
	if !game_session_data or game_session_data.is_empty():
		current_game_session = GameSession.create()
	else:
		current_game_session = GameSession.deserialize(game_session_data)

	get_tree().current_scene.queue_free()
	get_tree().root.add_child(current_game_session)
	get_tree().current_scene = current_game_session
