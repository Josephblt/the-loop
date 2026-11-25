class_name Chest
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer


func _interact() -> void:
	super._interact()
	open()


func open() -> void:
	chest_animation_player.play("open")


func open_immediately() -> void:
	chest_animation_player.play("open_immediately")
	trigger_interaction(false)