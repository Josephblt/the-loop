class_name Chest
extends Interactable


@onready var chest_animations: AnimationPlayer = %AnimationPlayer


func _interact() -> void:
	chest_animations.play("open")
