@tool
class_name LevelRandomizationActions
extends RefCounted


const SEED_METADATA: StringName = &"_randomization_seed"

var _rules: Array[LevelRandomizationRule] = []
var _undo_redo: EditorUndoRedoManager


func _init(undo_redo: EditorUndoRedoManager) -> void:
	_undo_redo = undo_redo
	_rules.append(BlockRandomizationRule.new())
	_rules.append(GateRandomizationRule.new())


func randomize_scene(
	scene_root: Node,
	settings: LevelRandomizationSettings
) -> int:
	var entries: Array[LevelRandomizationEntry] = _find_entries(scene_root)
	if entries.is_empty():
		return 0

	_undo_redo.create_action("Randomize Scene")

	var randomized_count: int = 0
	for entry: LevelRandomizationEntry in entries:
		var next_state: LevelRandomizationState = entry.rule.generate_state(
			entry.node,
			settings
		)
		if next_state == null:
			continue

		_add_state_change(
			scene_root,
			entry,
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
	var entries: Array[LevelRandomizationEntry] = _find_entries(scene_root)
	if entries.is_empty():
		return 0

	_undo_redo.create_action("Reset Scene Randomization")

	var reset_count: int = 0
	for entry: LevelRandomizationEntry in entries:
		var original_state: LevelRandomizationState = (
			entry.rule.get_original_state(entry.node)
		)
		if original_state == null:
			continue
		if not _is_randomized(entry, original_state):
			continue

		_add_state_change(
			scene_root,
			entry,
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


func _find_entries(scene_root: Node) -> Array[LevelRandomizationEntry]:
	var entries: Array[LevelRandomizationEntry] = []

	for child: Node in scene_root.get_children():
		_find_entries_recursive(child, entries)

	return entries


func _find_entries_recursive(
	node: Node,
	entries: Array[LevelRandomizationEntry]
) -> void:
	if node is Node3D:
		for rule: LevelRandomizationRule in _rules:
			if rule.can_handle(node):
				entries.append(LevelRandomizationEntry.new(
					node as Node3D,
					rule
				))
				break

	for child: Node in node.get_children():
		_find_entries_recursive(child, entries)


func _is_randomized(
	entry: LevelRandomizationEntry,
	original_state: LevelRandomizationState
) -> bool:
	if entry.node.has_meta(SEED_METADATA):
		return true

	var target: Node3D = entry.rule.get_target(entry.node)
	if target == null:
		return false

	return (
		target.position != original_state.position
		or target.rotation != original_state.rotation
	)


func _add_state_change(
	edited_root: Node,
	entry: LevelRandomizationEntry,
	next_state: LevelRandomizationState,
	keep_seed: bool,
	seed: int
) -> void:
	var target: Node3D = entry.rule.get_target(entry.node)
	if target == null:
		return

	var previous_position: Vector3 = target.position
	var previous_rotation: Vector3 = target.rotation
	var had_seed: bool = entry.node.has_meta(SEED_METADATA)
	var previous_seed: int = int(entry.node.get_meta(SEED_METADATA, 0))
	var is_scene_root: bool = entry.node == edited_root
	var was_editable: bool = (
		is_scene_root or edited_root.is_editable_instance(entry.node)
	)

	if not was_editable:
		_undo_redo.add_do_method(
			edited_root,
			&"set_editable_instance",
			entry.node,
			true
		)
		_undo_redo.add_undo_method(
			edited_root,
			&"set_editable_instance",
			entry.node,
			false
		)

	_undo_redo.add_do_property(target, &"position", next_state.position)
	_undo_redo.add_do_property(target, &"rotation", next_state.rotation)
	_undo_redo.add_undo_property(target, &"position", previous_position)
	_undo_redo.add_undo_property(target, &"rotation", previous_rotation)

	if keep_seed:
		_undo_redo.add_do_method(
			entry.node,
			&"set_meta",
			SEED_METADATA,
			seed
		)
	else:
		_undo_redo.add_do_method(
			entry.node,
			&"remove_meta",
			SEED_METADATA
		)

	if had_seed:
		_undo_redo.add_undo_method(
			entry.node,
			&"set_meta",
			SEED_METADATA,
			previous_seed
		)
	else:
		_undo_redo.add_undo_method(
			entry.node,
			&"remove_meta",
			SEED_METADATA
		)
