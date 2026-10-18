@tool
class_name RandomizationPlugin
extends EditorPlugin

const CATALOG_PATH: String = "res://addons/level_randomization/config/randomization_catalog.tres"
const LAYOUT_SECTION: String = "level_randomization"

var _actions: RandomizationActions
var _catalog: RandomizationCatalog
var _dock: RandomizationDock
var _editor_selection: EditorSelection
var _settings: RandomizationSettings
var _target_path_inspector: EditorInspectorPlugin


func _enter_tree() -> void:
	_catalog = load(CATALOG_PATH) as RandomizationCatalog
	if !_catalog:
		push_error("Unable to load level randomization catalog.")
		return

	_settings = RandomizationSettings.new()
	_actions = RandomizationActions.new(get_undo_redo(), _catalog)
	_target_path_inspector = TargetPathInspector.new(_catalog)
	add_inspector_plugin(_target_path_inspector)
	_dock = RandomizationDock.new(_settings, _catalog)

	_dock.randomize_scene_requested.connect(_randomize_scene)
	_dock.reset_scene_requested.connect(_reset_scene)
	_dock.settings_changed.connect(queue_save_layout)
	_dock.catalog_changed.connect(_refresh_availability)
	_editor_selection = EditorInterface.get_selection()
	_editor_selection.selection_changed.connect(_refresh_availability)
	scene_changed.connect(_on_scene_changed)

	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, _dock)
	call_deferred("_refresh_availability")


func _exit_tree() -> void:
	if _target_path_inspector:
		remove_inspector_plugin(_target_path_inspector)
		_target_path_inspector = null

	if scene_changed.is_connected(_on_scene_changed):
		scene_changed.disconnect(_on_scene_changed)
	
	if _editor_selection and _editor_selection.selection_changed.is_connected(_refresh_availability):
		_editor_selection.selection_changed.disconnect(_refresh_availability)

	if _dock:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null

	_actions = null
	_catalog = null
	_editor_selection = null
	_settings = null


func _get_window_layout(configuration: ConfigFile) -> void:
	if !_settings:
		return

	configuration.set_value(LAYOUT_SECTION, "seed", _settings.seed)


func _set_window_layout(configuration: ConfigFile) -> void:
	if !_settings:
		return

	var seed_value = configuration.get_value(LAYOUT_SECTION, "seed", _settings.seed)
	_settings.seed = int(seed_value)

	if _dock:
		_dock.refresh()


func _randomize_scene() -> void:
	var scene_root: Node = EditorInterface.get_edited_scene_root()
	if !scene_root:
		_dock.set_status("Open a scene before randomizing.")
		return

	var randomized_count: int = _actions.randomize_scene(scene_root, _settings)
	_dock.set_status("Randomized %d target(s)." % randomized_count)


func _reset_scene() -> void:
	var scene_root: Node = EditorInterface.get_edited_scene_root()
	if !scene_root:
		_dock.set_status("Open a scene before resetting.")
		return

	var reset_count: int = _actions.reset_scene(scene_root)
	_dock.set_status("Reset %d target(s)." % reset_count)


func _on_scene_changed(_scene_root: Node) -> void:
	_refresh_availability()


func _refresh_availability() -> void:
	if !_dock or !_actions:
		return

	var scene_root: Node = EditorInterface.get_edited_scene_root()
	var target_count: int = 0
	if scene_root != null:
		target_count = _actions.count_randomizable_targets(scene_root)

	_dock.set_available_target_count(target_count)
