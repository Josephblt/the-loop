@tool
extends RefCounted


const BLOCK_SCENES_DIRECTORY: String = "res://game/level/blocks/"
const TARGET_NODE_PATH: NodePath = ^"MeshInstance3D"


static func can_handle(object: Object) -> bool:
	if not object is StaticBody3D:
		return false

	var block: StaticBody3D = object as StaticBody3D
	return (
		block.scene_file_path.begins_with(BLOCK_SCENES_DIRECTORY)
		and get_target(block) != null
	)


static func find_blocks(scene_root: Node) -> Array[Node3D]:
	var blocks: Array[Node3D] = []

	for child: Node in scene_root.get_children():
		_find_blocks_recursive(child, blocks)

	return blocks


static func get_target(block: Node3D) -> Node3D:
	return block.get_node_or_null(TARGET_NODE_PATH) as Node3D


static func generate_state(
	block: Node3D,
	settings: LevelRandomizationSettings
) -> LevelRandomizationState:
	var original_state: LevelRandomizationState = get_original_state(block)
	if original_state == null:
		return null

	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = hash([
		settings.seed,
		block.scene_file_path,
		str(block.get_path()),
	])

	var position_offset: Vector3 = Vector3(
		randomizer.randf_range(
			-settings.position_variation.x,
			settings.position_variation.x
		),
		randomizer.randf_range(
			-settings.position_variation.y,
			settings.position_variation.y
		),
		randomizer.randf_range(
			-settings.position_variation.z,
			settings.position_variation.z
		)
	)
	var rotation_offset: Vector3 = Vector3(
		deg_to_rad(randomizer.randf_range(
			-settings.rotation_variation_degrees.x,
			settings.rotation_variation_degrees.x
		)),
		deg_to_rad(randomizer.randf_range(
			-settings.rotation_variation_degrees.y,
			settings.rotation_variation_degrees.y
		)),
		deg_to_rad(randomizer.randf_range(
			-settings.rotation_variation_degrees.z,
			settings.rotation_variation_degrees.z
		))
	)

	if randomizer.randi_range(0, 1) == 1:
		rotation_offset.y += PI

	return LevelRandomizationState.new(
		original_state.position + position_offset,
		original_state.rotation + rotation_offset
	)


static func get_original_state(block: Node3D) -> LevelRandomizationState:
	var block_scene: PackedScene = load(block.scene_file_path) as PackedScene
	if block_scene == null:
		return null

	var original_block: Node3D = block_scene.instantiate() as Node3D
	if original_block == null:
		return null

	var original_target: Node3D = get_target(original_block)
	if original_target == null:
		original_block.free()
		return null

	var state: LevelRandomizationState = LevelRandomizationState.new(
		original_target.position,
		original_target.rotation
	)
	original_block.free()
	return state


static func _find_blocks_recursive(
	node: Node,
	blocks: Array[Node3D]
) -> void:
	if can_handle(node):
		blocks.append(node as Node3D)

	for child: Node in node.get_children():
		_find_blocks_recursive(child, blocks)
