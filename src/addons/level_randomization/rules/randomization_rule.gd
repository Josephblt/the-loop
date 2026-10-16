@tool
class_name LevelRandomizationRule
extends RefCounted


const TARGET_NODE_PATH: NodePath = ^"MeshInstance3D"


func can_handle(_object: Object) -> bool:
	return false


func get_target(randomizable_node: Node3D) -> Node3D:
	return randomizable_node.get_node_or_null(TARGET_NODE_PATH) as Node3D


func generate_state(
	randomizable_node: Node3D,
	settings: LevelRandomizationSettings
) -> LevelRandomizationState:
	var original_state: LevelRandomizationState = get_original_state(
		randomizable_node
	)
	if original_state == null:
		return null

	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	var randomizer_seed: int = hash([
		settings.seed,
		randomizable_node.scene_file_path,
		str(randomizable_node.get_path()),
	])
	randomizer.seed = randomizer_seed

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

	if _can_invert() and randomizer.randi_range(0, 1) == 1:
		position_offset += _get_inversion_position_offset()
		rotation_offset.y += PI

	return LevelRandomizationState.new(
		original_state.position + position_offset,
		original_state.rotation + rotation_offset
	)


func get_original_state(
	randomizable_node: Node3D
) -> LevelRandomizationState:
	var source_scene: PackedScene = load(
		randomizable_node.scene_file_path
	) as PackedScene
	if source_scene == null:
		return null

	var original_node: Node3D = source_scene.instantiate() as Node3D
	if original_node == null:
		return null

	var original_target: Node3D = get_target(original_node)
	if original_target == null:
		original_node.free()
		return null

	var state: LevelRandomizationState = LevelRandomizationState.new(
		original_target.position,
		original_target.rotation
	)
	original_node.free()
	return state


func _get_inversion_position_offset() -> Vector3:
	return Vector3.ZERO


func _can_invert() -> bool:
	return true
