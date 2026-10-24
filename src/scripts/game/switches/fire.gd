class_name Fire
extends GeometryInstance3D


@onready var fire_light: OmniLight3D = $Light
@onready var fire_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	fire_light.visible = self.emitting


func is_lit() -> bool:
	return self.emitting


func ignite() -> void:
	self.emitting = true
	fire_light.visible = true

	if not fire_audio.playing:
		fire_audio.play()


func extinguish() -> void:
	self.emitting = false
	fire_light.visible = false
	fire_audio.stop()
