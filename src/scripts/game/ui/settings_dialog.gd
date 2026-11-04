class_name SettingsDialog
extends CanvasLayer


signal mouse_sensitivity_changed(value: float)
signal run_speed_changed(value: float)
signal walk_speed_changed(value: float)


const MAIN_MENU_SCENE_PATH: String = "uid://cfd01q26as6sx"
const SPEED_SLIDER_SCALE: float = 10.0
const ROMAN_LOOP_NUMBERS: Array[String] = ["I", "II", "III"]

@onready var game_session: GameSession = get_node("/root/GameSession")

@onready var mouse_sensitivity_slider: HSlider = %MouseSensitivitySlider
@onready var mouse_sensitivity_value: Label = %MouseSensitivityValue
@onready var run_speed_value: Label = %RunSpeedValue
@onready var walk_speed_value: Label = %WalkSpeedValue
@onready var fullscreen_button: Button = %FullscreenButton
@onready var mouse_mode_button: Button = %MouseModeButton
@onready var session_seed_value: Label = %SessionSeedValue
@onready var story_title_value: Label = %StoryTitleValue
@onready var loop_value: Label = %LoopValue
@onready var grief_stage_value: Label = %GriefStageValue
@onready var collected_memories_value: Label = %CollectedMemoriesValue


func _ready() -> void:
	mouse_sensitivity_slider.set_value_no_signal(Player.DEFAULT_MOUSE_SENSITIVITY)
	_on_mouse_sensitivity_slider_value_changed(mouse_sensitivity_slider.value)


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
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_mode_button.button_pressed = true
		mouse_mode_button.text = "Mouse Captured"
	else:
		mouse_mode_button.button_pressed = false
		mouse_mode_button.text = "Mouse Visible"

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_update_debug_info()
	_update_fullscreen_button()
	mouse_sensitivity_slider.grab_focus()


func _close() -> void:
	visible = false
	get_tree().paused = false
	if mouse_mode_button.button_pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_mouse_sensitivity_slider_value_changed(value: float) -> void:
	mouse_sensitivity_value.text = str(snappedf(value, 0.01))
	mouse_sensitivity_changed.emit(value)


func _on_run_speed_slider_value_changed(value: float) -> void:
	run_speed_value.text = str(int(value))
	run_speed_changed.emit(value / SPEED_SLIDER_SCALE)


func _on_walk_speed_slider_value_changed(value: float) -> void:
	walk_speed_value.text = str(int(value))
	walk_speed_changed.emit(value / SPEED_SLIDER_SCALE)


func _on_fullscreen_button_pressed() -> void:
	var fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	var mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(mode)
	fullscreen_button.text = "Enter Fullscreen" if fullscreen else "Exit Fullscreen"


func _update_fullscreen_button() -> void:
	var fullscreen: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_button.text = "Exit Fullscreen" if fullscreen else "Enter Fullscreen"


func _update_debug_info() -> void:
	var loop_number: int = game_session.loop_number()
	session_seed_value.text = str(game_session.session_seed())
	story_title_value.text = game_session.story_title()
	loop_value.text = "%s - %s" % [_roman_loop_number(loop_number), game_session.loop_title()]
	grief_stage_value.text = game_session.current_grief_stage_name()
	collected_memories_value.text = "%d / %d" % [game_session.collected_memories_count(), game_session.total_memories_count()]


func _roman_loop_number(loop_number: int) -> String:
	if loop_number > 0 and loop_number <= ROMAN_LOOP_NUMBERS.size():
		return ROMAN_LOOP_NUMBERS[loop_number - 1]
	return str(loop_number)


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func _on_mouse_state_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mouse_mode_button.text = "Mouse Captured"
	else:
		mouse_mode_button.text = "Mouse Visible"


func _on_close_button_pressed() -> void:
	_close()


func _on_save_button_pressed() -> void:
	game_session.update_save_data()
