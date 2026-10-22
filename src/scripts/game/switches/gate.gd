class_name Gate
extends Node3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var pulsating_energy_audio: AudioStreamPlayer3D = %PulsatingEnergyAudio
@onready var energy_activation_audio: AudioStreamPlayer3D = %EnergyActivationAudio
@onready var energy_deactivation_audio: AudioStreamPlayer3D = %EnergyDeactivationAudio

var active: bool = false


func _ready() -> void:
	_deactivate_immediately()


func is_active() -> bool:
	return active


func activate() -> void:
	energy_deactivation_audio.stop()
	energy_activation_audio.play()
	pulsating_energy_audio.play()
	animation_player.play("activate")
	await animation_player.animation_finished
	active = true
	

func deactivate() -> void:
	energy_activation_audio.stop()
	pulsating_energy_audio.stop()
	energy_deactivation_audio.play()
	animation_player.play("deactivate")
	await animation_player.animation_finished
	active = false


func _deactivate_immediately() -> void:
	energy_activation_audio.stop()
	pulsating_energy_audio.stop()
	energy_deactivation_audio.stop()
	animation_player.play("deactivate")
	animation_player.seek(animation_player.current_animation_length, true)
	animation_player.pause()	
	active = false


func _on_activator_body_exited(_body: Node3D) -> void:
	activate()
