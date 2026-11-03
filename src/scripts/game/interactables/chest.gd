class_name Chest
extends Interactable


@onready var chest_animation_player: AnimationPlayer = %ChestAnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer3D = %AudioStreamPlayer3D


func _interact() -> void:
	chest_animation_player.play("open")
	await chest_animation_player.animation_finished
	interaction_triggered.emit(self)


func open_immediately() -> void:
	chest_animation_player.play("open_immediately")
	audio_stream_player.stop()
	trigger_interaction(false)
