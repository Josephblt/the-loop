class_name Message
extends CanvasLayer


signal message_shown()
signal message_hidden()


@onready var message_label: Label = %MessageLabel
@onready var tip_label: Control = %TipLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _message_visible: bool = false


func _process(_delta: float) -> void:
	if _message_visible and Input.is_action_just_pressed("Interact"):
		_hide_message()


func setup_message(memory_text: String) -> void:
	message_label.text = memory_text


func setup_tip(tip_text: String) -> void:
	tip_label.text = tip_text


func show_message() -> void:
	animation_player.play("show")
	await animation_player.animation_finished
	_message_visible = true
	message_shown.emit()


func _hide_message() -> void:
	animation_player.play("hide")
	await animation_player.animation_finished
	_message_visible = false
	message_hidden.emit()