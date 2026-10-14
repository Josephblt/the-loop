class_name Fire
extends Node3D


@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var fire_light: OmniLight3D = $Light
@onready var fire_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


func ignite() -> void:
	particles.emitting = true
	fire_light.visible = true

	if not fire_audio.playing:
		fire_audio.play()


func extinguish() -> void:
	particles.emitting = false
	fire_light.visible = false
	fire_audio.stop()
