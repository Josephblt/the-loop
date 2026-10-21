@tool
class_name RandomizationDock
extends VBoxContainer


const RANDOMIZE_TAB: int = 0

signal randomize_scene_requested
signal reset_scene_requested
signal settings_changed
signal catalog_changed

var _catalog: RandomizationCatalog
var _catalog_inspector: EditorInspector
var _catalog_save_queued: bool = false
var _catalog_status_label: Label
var _randomize_button: Button
var _reset_button: Button
var _seed_input: SpinBox
var _seed_randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
var _settings: RandomizationSettings
var _status_label: Label


func _init(settings: RandomizationSettings, catalog: RandomizationCatalog) -> void:
	_settings = settings
	_catalog = catalog
	_seed_randomizer.randomize()
	name = "Level Randomization"
	_build_interface()


func refresh() -> void:
	_seed_input.value = _settings.seed


func set_available_target_count(target_count: int) -> void:
	var has_targets: bool = target_count > 0
	_randomize_button.disabled = !has_targets
	_reset_button.disabled = !has_targets

	if has_targets:
		_status_label.text = "%d configured target(s) found." % target_count
	else:
		_status_label.text = "No configured targets in this scene."


func set_status(message: String) -> void:
	_status_label.text = message


func _build_interface() -> void:
	var title: Label = Label.new()
	var tabs: TabContainer = TabContainer.new()
	var randomize_tab: VBoxContainer = VBoxContainer.new()
	var catalog_tab: VBoxContainer = VBoxContainer.new()
	var seed_row: HBoxContainer = HBoxContainer.new()
	var seed_label: Label = Label.new()
	var random_seed_button: Button = Button.new()
	var theme: Theme = EditorInterface.get_editor_theme()

	add_theme_constant_override("separation", 8)

	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.tab_changed.connect(_on_tab_changed)
	add_child(tabs)

	randomize_tab.name = "Randomize"
	randomize_tab.add_theme_constant_override("separation", 8)
	tabs.add_child(randomize_tab)

	catalog_tab.name = "Catalog"
	catalog_tab.add_theme_constant_override("separation", 8)
	tabs.add_child(catalog_tab)

	seed_label.text = "Seed"
	seed_label.custom_minimum_size.x = 80
	_seed_input = _create_spin_box(-2147483648.0, 2147483647.0, 1.0)
	_seed_input.value_changed.connect(_on_seed_changed)
	seed_row.add_child(seed_label)
	seed_row.add_child(_seed_input)
	randomize_tab.add_child(seed_row)


	random_seed_button.text = "Random Seed"
	random_seed_button.icon = theme.get_icon("RandomNumberGenerator", "EditorIcons")
	random_seed_button.pressed.connect(_on_random_seed_pressed)
	randomize_tab.add_child(random_seed_button)

	_randomize_button = Button.new()
	_randomize_button.text = "Randomize Scene"
	_randomize_button.icon = theme.get_icon("RandomNumberGenerator", "EditorIcons")
	_randomize_button.pressed.connect(_on_randomize_scene_pressed)
	randomize_tab.add_child(_randomize_button)

	_reset_button = Button.new()
	_reset_button.text = "Reset Scene"
	_reset_button.icon = theme.get_icon("Clear", "EditorIcons")
	_reset_button.pressed.connect(_on_reset_scene_pressed)
	randomize_tab.add_child(_reset_button)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	randomize_tab.add_child(_status_label)

	_catalog_inspector = EditorInspector.new()
	_catalog_inspector.custom_minimum_size.y = 320.0
	_catalog_inspector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_catalog_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_catalog_inspector.edit(_catalog)
	_catalog_inspector.property_edited.connect(_on_catalog_property_edited)
	catalog_tab.add_child(_catalog_inspector)

	_catalog_status_label = Label.new()
	_catalog_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_catalog_status_label.text = "Changes are saved automatically."
	catalog_tab.add_child(_catalog_status_label)

	refresh()
	set_available_target_count(0)


func _create_spin_box(minimum: float, maximum: float, step: float ) -> SpinBox:
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
	_seed_input.value = _seed_randomizer.randi_range(-2147483648, 2147483647)


func _on_randomize_scene_pressed() -> void:
	randomize_scene_requested.emit()


func _on_reset_scene_pressed() -> void:
	reset_scene_requested.emit()


func _on_tab_changed(tab: int) -> void:
	if tab == RANDOMIZE_TAB:
		catalog_changed.emit()


func _on_catalog_property_edited(_property: String) -> void:
	catalog_changed.emit()
	_catalog_status_label.text = "Saving catalog..."
	if _catalog_save_queued:
		return

	_catalog_save_queued = true
	call_deferred("_save_catalog")


func _save_catalog() -> void:
	_catalog_save_queued = false
	var catalog_path: String = _catalog.resource_path
	if catalog_path.is_empty():
		_catalog_status_label.text = "Unable to save an embedded catalog."
		return

	var save_error: Error = ResourceSaver.save(_catalog, catalog_path)
	if save_error == OK:
		_catalog_status_label.text = "Catalog saved. " + Time.get_date_string_from_system(true) + " " + Time.get_time_string_from_system(true)
		return

	_catalog_status_label.text = "Catalog save failed: %s" % error_string(save_error)
