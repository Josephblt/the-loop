@tool
extends EditorPlugin


const RandomizationDock: Script = preload("randomization_dock.gd")
const LAYOUT_SECTION: String = "level_randomization"

var _actions: LevelRandomizationActions
var _dock: LevelRandomizationDock
var _settings: LevelRandomizationSettings


func _enter_tree() -> void:
	_settings = LevelRandomizationSettings.new()
	_actions = LevelRandomizationActions.new(get_undo_redo())
	_dock = RandomizationDock.new(_settings)

	_dock.randomize_scene_requested.connect(_randomize_scene)
	_dock.reset_scene_requested.connect(_reset_scene)
	_dock.settings_changed.connect(queue_save_layout)

	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, _dock)


func _exit_tree() -> void:
	if _dock != null:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null

	_actions = null
	_settings = null


func _get_window_layout(configuration: ConfigFile) -> void:
	if _settings == null:
		return

	configuration.set_value(LAYOUT_SECTION, "seed", _settings.seed)
	configuration.set_value(
		LAYOUT_SECTION,
		"position_variation",
		_settings.position_variation
	)
	configuration.set_value(
		LAYOUT_SECTION,
		"rotation_variation_degrees",
		_settings.rotation_variation_degrees
	)


func _set_window_layout(configuration: ConfigFile) -> void:
	if _settings == null:
		return

	_settings.seed = int(configuration.get_value(
		LAYOUT_SECTION,
		"seed",
		_settings.seed
	))
	_settings.position_variation = configuration.get_value(
		LAYOUT_SECTION,
		"position_variation",
		_settings.position_variation
	) as Vector3
	_settings.rotation_variation_degrees = configuration.get_value(
		LAYOUT_SECTION,
		"rotation_variation_degrees",
		_settings.rotation_variation_degrees
	) as Vector3

	if _dock != null:
		_dock.refresh()


func _randomize_scene() -> void:
	var scene_root: Node = EditorInterface.get_edited_scene_root()
	if scene_root == null:
		_dock.set_status("Open a scene before randomizing.")
		return

	var randomized_count: int = _actions.randomize_scene(
		scene_root,
		_settings
	)
	_dock.set_status("Randomized %d object(s)." % randomized_count)


func _reset_scene() -> void:
	var scene_root: Node = EditorInterface.get_edited_scene_root()
	if scene_root == null:
		_dock.set_status("Open a scene before resetting.")
		return

	var reset_count: int = _actions.reset_scene(scene_root)
	_dock.set_status("Reset %d object(s)." % reset_count)
