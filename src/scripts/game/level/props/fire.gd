class_name Fire
extends CPUParticles3D


@onready var fire_light: OmniLight3D = $Light
@onready var fire_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


func is_lit() -> bool:
	return emitting


func ignite() -> void:
	emitting = true
	fire_light.visible = true

	if not fire_audio.playing:
		fire_audio.play()


func extinguish() -> void:
	emitting = false
	fire_light.visible = false
	fire_audio.stop()
