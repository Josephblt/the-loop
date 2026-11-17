class_name ChestGold
extends Chest


func dissolve() -> void:
	chest_animation_player.play("open_immediately")
	trigger_interaction(false)


func materialize() -> void:
	chest_animation_player.play("materialize")
	trigger_interaction(false)