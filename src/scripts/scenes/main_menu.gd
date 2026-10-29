class_name MainMenu
extends Node


const TEST_SCENE: PackedScene = preload("res://scenes/test_scene_menu.tscn")

@export var stories: Array[Story]

@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	_update_continue_button()


func _update_continue_button() -> void:
	continue_button.disabled = not FileAccess.file_exists(GameSession.SAVE_FILE_PATH)


func _on_new_game_pressed() -> void:
	var story = stories[randi() % stories.size()]
	GameSession.start(randi(), story)


func _on_continue_pressed() -> void:
	GameSession.deserialize()


func _on_tests_pressed() -> void:
	get_tree().change_scene_to_packed(TEST_SCENE)