class_name MainMenu
extends Node


const GAME_SESSION_SCENE: PackedScene = preload("res://scenes/game_session.tscn")
const TEST_SCENE: PackedScene = preload("res://scenes/test_scene_menu.tscn")

@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	_update_continue_button()


func _update_continue_button() -> void:
	continue_button.disabled = not FileAccess.file_exists(GameSession.SAVE_FILE_PATH)


func _on_new_game_pressed() -> void:
	GameSession.erase_save_data()
	GameSession.create_save_data()
	get_tree().change_scene_to_packed(GAME_SESSION_SCENE)


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_packed(GAME_SESSION_SCENE)


func _on_tests_pressed() -> void:
	get_tree().change_scene_to_packed(TEST_SCENE)
