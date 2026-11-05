class_name Fire
extends GeometryInstance3D


@onready var light: OmniLight3D = %Light
@onready var audio: AudioStreamPlayer3D = %AudioStreamPlayer3D


func _ready() -> void:
	if !Engine.is_editor_hint():
		self.emitting = true
	light.visible = self.emitting


func ignite() -> void:
	self.emitting = true
	light.visible = true

	if not audio.playing:
		audio.play()


func extinguish() -> void:
	self.emitting = false
	light.visible = false
	audio.stop()
