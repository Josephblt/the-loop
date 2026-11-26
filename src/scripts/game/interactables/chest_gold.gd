class_name ChestGold
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer


func _interact() -> void:
	super._interact()
	open()


func open() -> void:
	chest_animation_player.play("open")


func dissolve() -> void:
	chest_animation_player.play("dissolve")	


func materialize() -> void:
	chest_animation_player.play("materialize")
	_update_outline(false)
	_update_highlight(is_interactable)