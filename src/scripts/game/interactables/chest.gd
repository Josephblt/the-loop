class_name Chest
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _interact() -> void:
	chest_animation_player.play("open")
	await chest_animation_player.animation_finished
	_interaction_performed.emit()


func open_immediately() -> void:
	_is_interactable = false
	_update_highlight(false)
	_update_outline(false)
	chest_animation_player.play("open")
	chest_animation_player.seek(chest_animation_player.current_animation_length, true)
	chest_animation_player.pause()
	audio_stream_player.stop()
