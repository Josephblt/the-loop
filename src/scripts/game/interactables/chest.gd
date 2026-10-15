class_name Chest
extends Interactable


@onready var chest_animations: AnimationPlayer = %ChestAnimations


func _interact() -> void:
	chest_animations.play("open")
	await chest_animations.animation_finished
