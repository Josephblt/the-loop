@tool
extends EditorInspectorPlugin


const BlockRandomization = preload("rules/block_randomization.gd")
const SEED_METADATA: StringName = &"_randomization_seed"

var _undo_redo: EditorUndoRedoManager


func _init(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo


func _can_handle(object: Object) -> bool:
	return (
		object != EditorInterface.get_edited_scene_root()
		and BlockRandomization.can_handle(object)
	)


func _parse_begin(object: Object) -> void:
	var block := object as Node3D
	var controls := VBoxContainer.new()
	var seed_row := HBoxContainer.new()
	var seed_label := Label.new()
	var seed_input := SpinBox.new()
	var buttons := HBoxContainer.new()
	var randomize_button := Button.new()
	var reset_button := Button.new()

	seed_label.text = "Seed"
	seed_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	seed_input.allow_greater = true
	seed_input.allow_lesser = true
	seed_input.max_value = 2147483647
	seed_input.min_value = -2147483648
	seed_input.step = 1
	seed_input.value = block.get_meta(SEED_METADATA, 0)
	seed_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	randomize_button.text = "Randomize"
	randomize_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"RandomNumberGenerator",
		&"EditorIcons"
	)
	randomize_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	randomize_button.pressed.connect(
		_randomize.bind(block, seed_input)
	)

	reset_button.text = "Reset"
	reset_button.icon = EditorInterface.get_editor_theme().get_icon(
		&"Clear",
		&"EditorIcons"
	)
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset_button.pressed.connect(
		_reset.bind(block, seed_input)
	)

	seed_row.add_child(seed_label)
	seed_row.add_child(seed_input)
	buttons.add_child(randomize_button)
	buttons.add_child(reset_button)
	controls.add_child(seed_row)
	controls.add_child(buttons)
	add_custom_control(controls)


func _randomize(block: Node3D, seed_input: SpinBox) -> void:
	var target := BlockRandomization.get_target(block)
	if target == null:
		return

	var seed := int(seed_input.value)
	var next_state := BlockRandomization.generate_state(block, seed)
	if next_state.is_empty():
		return

	_commit_state(
		"Randomize Block",
		block,
		target,
		next_state,
		true,
		seed
	)


func _reset(block: Node3D, seed_input: SpinBox) -> void:
	var target := BlockRandomization.get_target(block)
	if target == null:
		return

	var original_state := BlockRandomization.get_original_state(block)
	if original_state.is_empty():
		return

	_commit_state(
		"Reset Block Randomization",
		block,
		target,
		original_state,
		false,
		0
	)
	seed_input.value = 0


func _commit_state(
	action_name: String,
	block: Node3D,
	target: Node3D,
	next_state: Dictionary,
	keep_seed: bool,
	seed: int
) -> void:
	var edited_root := EditorInterface.get_edited_scene_root()
	if edited_root == null:
		return

	var previous_position := target.position
	var previous_rotation := target.rotation
	var had_seed := block.has_meta(SEED_METADATA)
	var previous_seed: int = block.get_meta(SEED_METADATA, 0)
	var is_scene_root := block == edited_root
	var was_editable := is_scene_root or edited_root.is_editable_instance(block)

	_undo_redo.create_action(action_name)

	if not was_editable:
		_undo_redo.add_do_method(
			edited_root,
			&"set_editable_instance",
			block,
			true
		)
		_undo_redo.add_undo_method(
			edited_root,
			&"set_editable_instance",
			block,
			false
		)

	_undo_redo.add_do_property(target, &"position", next_state.position)
	_undo_redo.add_do_property(target, &"rotation", next_state.rotation)
	_undo_redo.add_undo_property(target, &"position", previous_position)
	_undo_redo.add_undo_property(target, &"rotation", previous_rotation)

	if keep_seed:
		_undo_redo.add_do_method(block, &"set_meta", SEED_METADATA, seed)
	else:
		_undo_redo.add_do_method(block, &"remove_meta", SEED_METADATA)

	if had_seed:
		_undo_redo.add_undo_method(
			block,
			&"set_meta",
			SEED_METADATA,
			previous_seed
		)
	else:
		_undo_redo.add_undo_method(block, &"remove_meta", SEED_METADATA)

	_undo_redo.commit_action()
