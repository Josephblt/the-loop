@tool
class_name RandomizationActions
extends RefCounted


const SEED_METADATA: StringName = "_randomization_seed"

var _catalog: RandomizationCatalog
var _undo_redo: EditorUndoRedoManager


func _init(undo_redo: EditorUndoRedoManager, catalog: RandomizationCatalog ) -> void:
	_undo_redo = undo_redo
	_catalog = catalog


func count_randomizable_targets(scene_root: Node) -> int:
	var entries: Array[RandomizationEntry] = SceneRandomizer.find_entries(scene_root, _catalog)
	return entries.size()


func randomize_scene(scene_root: Node, settings: RandomizationSettings ) -> int:
	var entries: Array[RandomizationEntry] = SceneRandomizer.find_entries(scene_root, _catalog)
	if entries.is_empty():
		return 0

	_undo_redo.create_action("Randomize Scene")

	var randomized_count: int = 0
	for entry: RandomizationEntry in entries:
		var target_binding: TargetRandomizationBinding = entry.target_binding
		if !target_binding.profile:
			continue

		var identity: String = SceneRandomizer.get_identity(scene_root, entry)
		var base_state: TransformRandomizationState = _get_base_state(entry, identity)
		if !base_state:
			continue

		var next_state: TransformRandomizationState = TransformRandomizer.generate(
			base_state.position, base_state.rotation, target_binding.profile, settings.seed, identity
		)

		_add_state_change(scene_root, entry, next_state, true, settings.seed)
		randomized_count += 1

	if randomized_count == 0:
		_undo_redo.commit_action(false)
		return 0

	_undo_redo.commit_action()
	return randomized_count


func reset_scene(scene_root: Node) -> int:
	var entries: Array[RandomizationEntry] = SceneRandomizer.find_entries(scene_root, _catalog)
	if entries.is_empty():
		return 0

	_undo_redo.create_action("Reset Scene Randomization")

	var reset_count: int = 0
	for entry: RandomizationEntry in entries:
		if !entry.node.has_meta(SEED_METADATA):
			continue

		var identity: String = SceneRandomizer.get_identity(scene_root, entry)
		var base_state: TransformRandomizationState = _get_base_state(entry, identity)
		if !base_state:
			continue

		_add_state_change(scene_root, entry, base_state, false, 0)
		reset_count += 1

	if reset_count == 0:
		_undo_redo.commit_action(false)
		return 0

	_undo_redo.commit_action()
	return reset_count


func _get_base_state(entry: RandomizationEntry, identity: String) -> TransformRandomizationState:
	var target: Node3D = entry.target_binding.get_target(entry.node)
	if !target:
		return null

	var current_state: TransformRandomizationState = TransformRandomizationState.new(target.position, target.rotation)
	if !entry.node.has_meta(SEED_METADATA):
		return current_state

	var previous_seed: int = int(entry.node.get_meta(SEED_METADATA))
	var profile: TransformRandomizationProfile = entry.target_binding.profile
	return TransformRandomizer.recover_base(current_state.position, current_state.rotation, profile, previous_seed, identity)


func _add_state_change(edited_root: Node, entry: RandomizationEntry, next_state: TransformRandomizationState, keep_seed: bool, seed: int ) -> void:
	var target_binding: TargetRandomizationBinding = entry.target_binding
	var target: Node3D = target_binding.get_target(entry.node)
	if !target:
		return

	var previous_position: Vector3 = target.position
	var previous_rotation: Vector3 = target.rotation
	
	var node: Node3D = entry.node
	var had_seed: bool = node.has_meta(SEED_METADATA)
	var previous_seed: int = int(node.get_meta(SEED_METADATA, 0))
	var is_scene_root: bool = node == edited_root
	var is_editable: bool = edited_root.is_editable_instance(node)
	var was_editable: bool = is_scene_root or is_editable

	if !was_editable:
		_undo_redo.add_do_method(edited_root, &"set_editable_instance", node, true)
		_undo_redo.add_undo_method(edited_root, &"set_editable_instance", node, false)

	_undo_redo.add_do_property(target, &"position", next_state.position)
	_undo_redo.add_do_property(target, &"rotation", next_state.rotation)
	_undo_redo.add_undo_property(target, &"position", previous_position)
	_undo_redo.add_undo_property(target, &"rotation", previous_rotation)

	if keep_seed:
		_undo_redo.add_do_method(node, &"set_meta", SEED_METADATA, seed)
	else:
		_undo_redo.add_do_method(node, &"remove_meta", SEED_METADATA)

	if had_seed:
		_undo_redo.add_undo_method(node, &"set_meta", SEED_METADATA, previous_seed)
	else:
		_undo_redo.add_undo_method(node, &"remove_meta", SEED_METADATA)
