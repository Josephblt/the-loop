@tool
class_name LevelRandomizationDock
extends VBoxContainer


signal randomize_scene_requested
signal reset_scene_requested
signal settings_changed

const AXIS_LABELS: Array[String] = ["X", "Y", "Z"]

var _position_inputs: Array[SpinBox] = []
var _rotation_inputs: Array[SpinBox] = []
var _seed_input: SpinBox
var _settings: LevelRandomizationSettings
var _status_label: Label


func _init(settings: LevelRandomizationSettings) -> void:
	_settings = settings
	name = "Level Randomization"
	_build_interface()


func refresh() -> void:
	_seed_input.value = _settings.seed

	for axis: int in range(3):
		_position_inputs[axis].value = _settings.position_variation[axis]
		_rotation_inputs[axis].value = (
			_settings.rotation_variation_degrees[axis]
		)


func set_status(message: String) -> void:
	_status_label.text = message


func _build_interface() -> void:
	var title: Label = Label.new()
	var seed_row: HBoxContainer = HBoxContainer.new()
	var seed_label: Label = Label.new()
	var randomize_button: Button = Button.new()
	var reset_button: Button = Button.new()

	add_theme_constant_override(&"separation", 8)

	title.text = "Block Randomization"
	title.add_theme_font_size_override(&"font_size", 16)
	add_child(title)

	seed_label.text = "Seed"
	seed_label.custom_minimum_size.x = 80
	_seed_input = _create_spin_box(-2147483648.0, 2147483647.0, 1.0)
	_seed_input.value_changed.connect(_on_seed_changed)
	seed_row.add_child(seed_label)
	seed_row.add_child(_seed_input)
	add_child(seed_row)

	_add_vector_editor(
		"Position Variation",
		_settings.position_variation,
		_position_inputs,
		Callable(self, &"_on_position_variation_changed"),
		0.001,
		" m"
	)
	_add_vector_editor(
		"Rotation Variation",
		_settings.rotation_variation_degrees,
		_rotation_inputs,
		Callable(self, &"_on_rotation_variation_changed"),
		0.1,
		"°"
	)

	randomize_button.text = "Randomize Scene"
	randomize_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"RandomNumberGenerator",
		&"EditorIcons"
	)
	randomize_button.pressed.connect(_on_randomize_scene_pressed)
	add_child(randomize_button)

	reset_button.text = "Reset Scene"
	reset_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"Clear",
		&"EditorIcons"
	)
	reset_button.pressed.connect(_on_reset_scene_pressed)
	add_child(reset_button)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status_label)

	refresh()


func _add_vector_editor(
	label_text: String,
	value: Vector3,
	inputs: Array[SpinBox],
	change_handler: Callable,
	step: float,
	suffix: String
) -> void:
	var label: Label = Label.new()
	var row: HBoxContainer = HBoxContainer.new()

	label.text = label_text
	add_child(label)

	for axis: int in range(3):
		var axis_label: Label = Label.new()
		var input: SpinBox = _create_spin_box(0.0, 360.0, step)

		axis_label.text = AXIS_LABELS[axis]
		input.value = value[axis]
		input.suffix = suffix
		input.value_changed.connect(change_handler.bind(axis))
		inputs.append(input)
		row.add_child(axis_label)
		row.add_child(input)

	add_child(row)


func _create_spin_box(
	minimum: float,
	maximum: float,
	step: float
) -> SpinBox:
	var input: SpinBox = SpinBox.new()
	input.min_value = minimum
	input.max_value = maximum
	input.step = step
	input.allow_greater = true
	input.allow_lesser = minimum < 0.0
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return input


func _on_seed_changed(value: float) -> void:
	_settings.seed = int(value)
	settings_changed.emit()


func _on_position_variation_changed(value: float, axis: int) -> void:
	_settings.position_variation[axis] = value
	settings_changed.emit()


func _on_rotation_variation_changed(value: float, axis: int) -> void:
	_settings.rotation_variation_degrees[axis] = value
	settings_changed.emit()


func _on_randomize_scene_pressed() -> void:
	randomize_scene_requested.emit()


func _on_reset_scene_pressed() -> void:
	reset_scene_requested.emit()
