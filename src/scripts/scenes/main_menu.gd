class_name MainMenu
extends Node


@export var story: Story

@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	_update_continue_button()


func _update_continue_button() -> void:
	continue_button.disabled = not FileAccess.file_exists(GameSession.SAVE_FILE_PATH)


func continue_game():
	GameSession.deserialize()


func new_game() -> void:
	assert(story != null, "MainMenu requires a story")
	GameSession.start(randi(), story)


func _on_continue_pressed() -> void:
	continue_game()


func _on_new_game_pressed() -> void:
	new_game()
