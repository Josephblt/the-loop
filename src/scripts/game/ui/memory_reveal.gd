class_name MemoryReveal
extends CanvasLayer


signal revealed()
signal dismissed()


@onready var memory_label: Label = %MemoryLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _visible: bool = false

func _process(_delta: float) -> void:
	if _visible and Input.is_action_just_pressed("Interact"):
		_dismiss()


func reveal(memory_text: String) -> void:
	memory_label.text = memory_text
	revealed.emit()
	animation_player.play("show")
	await animation_player.animation_finished
	_visible = true


func _dismiss() -> void:
	_visible = false
	animation_player.play("hide")
	await animation_player.animation_finished
	dismissed.emit()