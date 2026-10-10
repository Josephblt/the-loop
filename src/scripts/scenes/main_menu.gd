class_name MainMenu
extends Node


@onready var continue_button = %ContinueButton


func _ready() -> void:
	_update_continue_button()


func _update_continue_button() -> void:
	continue_button.disabled = not GameManager._has_saved_game_session()


func _on_continue_pressed() -> void:
	GameManager.load_game()


func _on_new_game_pressed() -> void:
	GameManager.start_game()
