@tool
class_name LevelRandomizationActions
extends RefCounted


const BlockRandomization: Script = preload("rules/block_randomization.gd")
const SEED_METADATA: StringName = &"_randomization_seed"

var _undo_redo: EditorUndoRedoManager


func _init(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo


func randomize_block(
	block: Node3D,
	settings: LevelRandomizationSettings
) -> bool:
	var next_state: LevelRandomizationState = BlockRandomization.generate_state(
		block,
		settings
	)
	if next_state == null:
		return false

	var edited_root: Node = EditorInterface.get_edited_scene_root()
	if edited_root == null:
		return false

	_undo_redo.create_action("Randomize Block")
	_add_state_change(
		edited_root,
		block,
		next_state,
		true,
		settings.seed
	)
	_undo_redo.commit_action()
	return true


func reset_block(block: Node3D) -> bool:
	var original_state: LevelRandomizationState = (
		BlockRandomization.get_original_state(block)
	)
	if original_state == null:
		return false
	if not _is_randomized(block, original_state):
		return false

	var edited_root: Node = EditorInterface.get_edited_scene_root()
	if edited_root == null:
		return false

	_undo_redo.create_action("Reset Block Randomization")
	_add_state_change(
		edited_root,
		block,
		original_state,
		false,
		0
	)
	_undo_redo.commit_action()
	return true


func randomize_scene(
	scene_root: Node,
	settings: LevelRandomizationSettings
) -> int:
	var blocks: Array[Node3D] = BlockRandomization.find_blocks(scene_root)
	if blocks.is_empty():
		return 0

	_undo_redo.create_action("Randomize Scene Blocks")

	var randomized_count: int = 0
	for block: Node3D in blocks:
		var next_state: LevelRandomizationState = (
			BlockRandomization.generate_state(block, settings)
		)
		if next_state == null:
			continue

		_add_state_change(
			scene_root,
			block,
			next_state,
			true,
			settings.seed
		)
		randomized_count += 1

	if randomized_count == 0:
		_undo_redo.commit_action(false)
		return 0

	_undo_redo.commit_action()
	return randomized_count


func reset_scene(scene_root: Node) -> int:
	var blocks: Array[Node3D] = BlockRandomization.find_blocks(scene_root)
	if blocks.is_empty():
		return 0

	_undo_redo.create_action("Reset Scene Blocks")

	var reset_count: int = 0
	for block: Node3D in blocks:
		var original_state: LevelRandomizationState = (
			BlockRandomization.get_original_state(block)
		)
		if original_state == null:
			continue
		if not _is_randomized(block, original_state):
			continue

		_add_state_change(
			scene_root,
			block,
			original_state,
			false,
			0
		)
		reset_count += 1

	if reset_count == 0:
		_undo_redo.commit_action(false)
		return 0

	_undo_redo.commit_action()
	return reset_count


func _is_randomized(
	block: Node3D,
	original_state: LevelRandomizationState
) -> bool:
	if block.has_meta(SEED_METADATA):
		return true

	var target: Node3D = BlockRandomization.get_target(block)
	if target == null:
		return false

	return (
		target.position != original_state.position
		or target.rotation != original_state.rotation
	)


func _add_state_change(
	edited_root: Node,
	block: Node3D,
	next_state: LevelRandomizationState,
	keep_seed: bool,
	seed: int
) -> void:
	var target: Node3D = BlockRandomization.get_target(block)
	if target == null:
		return

	var previous_position: Vector3 = target.position
	var previous_rotation: Vector3 = target.rotation
	var had_seed: bool = block.has_meta(SEED_METADATA)
	var previous_seed: int = int(block.get_meta(SEED_METADATA, 0))
	var is_scene_root: bool = block == edited_root
	var was_editable: bool = (
		is_scene_root or edited_root.is_editable_instance(block)
	)

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
