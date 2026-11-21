class_name Chest
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer


func _interact() -> void:
	open()


func open() -> void:
	chest_animation_player.play("open")
	await chest_animation_player.animation_finished
	interaction_triggered.emit(self)


func open_immediately() -> void:
	chest_animation_player.play("open_immediately")
	trigger_interaction(false)