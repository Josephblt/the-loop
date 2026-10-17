@tool
class_name LevelSceneRandomizationBinding
extends Resource


@export var source_scene: PackedScene
@export var targets: Array[LevelTargetRandomizationBinding] = []


func matches(scene_path: String) -> bool:
	return (
		source_scene != null
		and source_scene.resource_path == scene_path
	)


func get_authored_state(
	target_binding: LevelTargetRandomizationBinding
) -> TransformRandomizationState:
	if source_scene == null:
		return null

	var source_root: Node3D = source_scene.instantiate() as Node3D
	if source_root == null:
		return null

	var target: Node3D = target_binding.get_target(source_root)
	if target == null:
		source_root.free()
		return null

	var state: TransformRandomizationState = TransformRandomizationState.new(
		target.position,
		target.rotation
	)
	source_root.free()
	return state
