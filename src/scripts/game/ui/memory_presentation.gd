class_name MemoryPresentation
extends CanvasLayer


signal dismissed()


@export_range(0.0, 3.0) var reveal_duration: float = 0.7
@export_range(0.0, 3.0) var dismiss_duration: float = 1.0
@export var dismiss_action: StringName = &"Interact"

@onready var dream_veil: ColorRect = %DreamVeil
@onready var memory_label: Label = %MemoryLabel

var _transition: Tween


func _ready() -> void:
	set_process_unhandled_input(false)
	_set_intensity(0.0)
	memory_label.modulate.a = 0.0
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(dismiss_action):
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		dismiss()


func present(memory_text: String) -> void:
	_stop_transition()
	set_process_unhandled_input(false)
	memory_label.text = memory_text
	memory_label.modulate.a = 0.0
	_set_intensity(0.0)
	show()

	_transition = create_tween()
	_transition.set_parallel()
	_transition.tween_method(
		_set_intensity,
		0.0,
		1.0,
		reveal_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_transition.tween_property(
		memory_label,
		"modulate:a",
		1.0,
		reveal_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_transition.chain().tween_callback(
		set_process_unhandled_input.bind(true)
	)


func dismiss() -> void:
	if not visible:
		return

	_stop_transition()
	set_process_unhandled_input(false)
	_transition = create_tween()
	_transition.set_parallel()
	_transition.tween_method(
		_set_intensity,
		_get_intensity(),
		0.0,
		dismiss_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_transition.tween_property(
		memory_label,
		"modulate:a",
		0.0,
		dismiss_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_transition.chain().tween_callback(_finish_dismissal)


func _get_material() -> ShaderMaterial:
	return dream_veil.material as ShaderMaterial


func _get_intensity() -> float:
	return _get_material().get_shader_parameter("intensity") as float


func _set_intensity(value: float) -> void:
	_get_material().set_shader_parameter("intensity", value)


func _stop_transition() -> void:
	if _transition and _transition.is_valid():
		_transition.kill()


func _finish_dismissal() -> void:
	hide()
	dismissed.emit()
