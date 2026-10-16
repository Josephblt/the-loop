class_name Chest
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer


func _interact() -> void:
	chest_animation_player.play("open")
	await chest_animation_player.animation_finished
	_interaction_performed.emit()
