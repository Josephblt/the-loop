class_name ChestGold
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer


func _interact() -> void:
	open()


func open() -> void:
	chest_animation_player.play("open")
	await chest_animation_player.animation_finished
	interaction_triggered.emit(self)


func dissolve() -> void:
	chest_animation_player.play("dissolve")
	trigger_interaction(false)


func materialize() -> void:
	chest_animation_player.play("materialize")
	trigger_interaction(false)