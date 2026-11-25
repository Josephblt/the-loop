class_name Chest
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer


func _interact() -> void:
	open()


func open() -> void:
	interaction_triggered.emit(self)
	chest_animation_player.play("open")


func open_immediately() -> void:
	chest_animation_player.play("open_immediately")
	trigger_interaction(false)