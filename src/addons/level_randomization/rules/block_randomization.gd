@tool
extends RefCounted


const BLOCK_SCENES_DIRECTORY := "res://game/level/blocks/"
const TARGET_NODE_NAME := &"MeshInstance3D"

const POSITION_VARIATION := Vector3(0.01, 0.01, 0.01)
const ROTATION_VARIATION_DEGREES := Vector3(0.1, 0.1, 0.1)


static func can_handle(object: Object) -> bool:
	if not object is StaticBody3D:
		return false

	var block := object as StaticBody3D
	return (
		block.scene_file_path.begins_with(BLOCK_SCENES_DIRECTORY)
		and get_target(block) != null
	)


static func get_target(block: Node3D) -> Node3D:
	return block.get_node_or_null(NodePath(str(TARGET_NODE_NAME))) as Node3D


static func generate_state(block: Node3D, seed: int) -> Dictionary:
	var original_state := get_original_state(block)
	if original_state.is_empty():
		return {}

	var rng := RandomNumberGenerator.new()
	rng.seed = hash([
		seed,
		block.scene_file_path,
		str(block.get_path()),
	])

	var position_offset := Vector3(
		rng.randf_range(-POSITION_VARIATION.x, POSITION_VARIATION.x),
		rng.randf_range(-POSITION_VARIATION.y, POSITION_VARIATION.y),
		rng.randf_range(-POSITION_VARIATION.z, POSITION_VARIATION.z)
	)
	var rotation_offset := Vector3(
		deg_to_rad(rng.randf_range(
			-ROTATION_VARIATION_DEGREES.x,
			ROTATION_VARIATION_DEGREES.x
		)),
		deg_to_rad(rng.randf_range(
			-ROTATION_VARIATION_DEGREES.y,
			ROTATION_VARIATION_DEGREES.y
		)),
		deg_to_rad(rng.randf_range(
			-ROTATION_VARIATION_DEGREES.z,
			ROTATION_VARIATION_DEGREES.z
		))
	)

	if rng.randi_range(0, 1) == 1:
		rotation_offset.y += PI

	return {
		"position": original_state.position + position_offset,
		"rotation": original_state.rotation + rotation_offset,
	}


static func get_original_state(block: Node3D) -> Dictionary:
	var block_scene := load(block.scene_file_path) as PackedScene
	if block_scene == null:
		return {}

	var original_block := block_scene.instantiate() as Node3D
	if original_block == null:
		return {}

	var original_target := get_target(original_block)
	if original_target == null:
		original_block.free()
		return {}

	var state := {
		"position": original_target.position,
		"rotation": original_target.rotation,
	}
	original_block.free()
	return state
