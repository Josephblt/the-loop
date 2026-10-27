class_name MainMenu
extends Node


@onready var continue_button = %ContinueButton


func _ready() -> void:
	_update_continue_button()


func _update_continue_button() -> void:
	continue_button.disabled = not FileAccess.file_exists(GameSession.SAVE_FILE_PATH)


func continue_game():
	GameSession.deserialize()


func new_game():
	GameSession.start(randi())


func _on_continue_pressed() -> void:
	continue_game()


func _on_new_game_pressed() -> void:
	new_game()
