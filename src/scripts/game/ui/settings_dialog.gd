class_name SettingsDialog
extends CanvasLayer


signal mouse_sensitivity_changed(value: float)
signal run_speed_changed(value: float)
signal walk_speed_changed(value: float)

const MAIN_MENU_SCENE_PATH: String = "res://scenes/main_menu.tscn"
const SLIDER_SCALE: float = 10.0

@onready var mouse_sensitivity_slider: HSlider = %MouseSensitivitySlider


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("Pause") or event.is_echo():
		return

	_toggle()
	get_viewport().set_input_as_handled()


func _toggle() -> void:
	if visible:
		_close()
	else:
		_open()


func _open() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse_sensitivity_slider.grab_focus()


func _close() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	mouse_sensitivity_changed.emit(value / SLIDER_SCALE)


func _on_run_speed_slider_value_changed(value: float) -> void:
	run_speed_changed.emit(value / SLIDER_SCALE)


func _on_walk_speed_slider_value_changed(value: float) -> void:
	walk_speed_changed.emit(value / SLIDER_SCALE)


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
