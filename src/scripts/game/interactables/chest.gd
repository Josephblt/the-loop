class_name Chest
extends Interactable


@onready var chest_animations: AnimationPlayer = %ChestAnimations


func _interact() -> Variant:
	chest_animations.play("open")
	return chest_animations.animation_finished
