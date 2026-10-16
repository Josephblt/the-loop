@tool
class_name LevelRandomizationDock
extends VBoxContainer


signal randomize_scene_requested
signal reset_scene_requested
signal settings_changed

var _randomize_button: Button
var _reset_button: Button
var _seed_input: SpinBox
var _seed_randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
var _settings: LevelRandomizationSettings
var _status_label: Label


func _init(settings: LevelRandomizationSettings) -> void:
	_settings = settings
	_seed_randomizer.randomize()
	name = "Level Randomization"
	_build_interface()


func refresh() -> void:
	_seed_input.value = _settings.seed


func set_available_target_count(target_count: int) -> void:
	var has_targets: bool = target_count > 0
	_randomize_button.disabled = not has_targets
	_reset_button.disabled = not has_targets

	if has_targets:
		_status_label.text = "%d configured object(s) found." % target_count
	else:
		_status_label.text = "No configured objects in this scene."


func set_status(message: String) -> void:
	_status_label.text = message


func _build_interface() -> void:
	var title: Label = Label.new()
	var seed_row: HBoxContainer = HBoxContainer.new()
	var seed_label: Label = Label.new()
	var random_seed_button: Button = Button.new()

	add_theme_constant_override(&"separation", 8)

	title.text = "Level Randomization"
	title.add_theme_font_size_override(&"font_size", 16)
	add_child(title)

	seed_label.text = "Seed"
	seed_label.custom_minimum_size.x = 80
	_seed_input = _create_spin_box(-2147483648.0, 2147483647.0, 1.0)
	_seed_input.value_changed.connect(_on_seed_changed)
	seed_row.add_child(seed_label)
	seed_row.add_child(_seed_input)
	add_child(seed_row)

	random_seed_button.text = "Random Seed"
	random_seed_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"RandomNumberGenerator",
		&"EditorIcons"
	)
	random_seed_button.pressed.connect(_on_random_seed_pressed)
	add_child(random_seed_button)

	_randomize_button = Button.new()
	_randomize_button.text = "Randomize Scene"
	_randomize_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"RandomNumberGenerator",
		&"EditorIcons"
	)
	_randomize_button.pressed.connect(_on_randomize_scene_pressed)
	add_child(_randomize_button)

	_reset_button = Button.new()
	_reset_button.text = "Reset Scene"
	_reset_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"Clear",
		&"EditorIcons"
	)
	_reset_button.pressed.connect(_on_reset_scene_pressed)
	add_child(_reset_button)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status_label)

	refresh()
	set_available_target_count(0)


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


func _on_random_seed_pressed() -> void:
	_seed_input.value = _seed_randomizer.randi_range(
		-2147483648,
		2147483647
	)


func _on_randomize_scene_pressed() -> void:
	randomize_scene_requested.emit()


func _on_reset_scene_pressed() -> void:
	reset_scene_requested.emit()
