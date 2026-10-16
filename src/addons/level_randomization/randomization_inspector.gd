@tool
extends EditorInspectorPlugin


const BlockRandomization: Script = preload("rules/block_randomization.gd")

var _actions: LevelRandomizationActions
var _settings: LevelRandomizationSettings


func _init(
	actions: LevelRandomizationActions,
	settings: LevelRandomizationSettings
) -> void:
	_actions = actions
	_settings = settings


func _can_handle(object: Object) -> bool:
	return (
		object != EditorInterface.get_edited_scene_root()
		and BlockRandomization.can_handle(object)
	)


func _parse_begin(object: Object) -> void:
	var block: Node3D = object as Node3D
	var controls: VBoxContainer = VBoxContainer.new()
	var settings_hint: Label = Label.new()
	var buttons: HBoxContainer = HBoxContainer.new()
	var randomize_button: Button = Button.new()
	var reset_button: Button = Button.new()

	settings_hint.text = "Uses the Level Randomization dock settings."
	settings_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	randomize_button.text = "Randomize"
	randomize_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"RandomNumberGenerator",
		&"EditorIcons"
	)
	randomize_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	randomize_button.pressed.connect(_randomize.bind(block))

	reset_button.text = "Reset"
	reset_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"Clear",
		&"EditorIcons"
	)
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.pressed.connect(_reset.bind(block))

	buttons.add_child(randomize_button)
	buttons.add_child(reset_button)
	controls.add_child(settings_hint)
	controls.add_child(buttons)
	add_custom_control(controls)


func _randomize(block: Node3D) -> void:
	_actions.randomize_block(block, _settings)


func _reset(block: Node3D) -> void:
	_actions.reset_block(block)
