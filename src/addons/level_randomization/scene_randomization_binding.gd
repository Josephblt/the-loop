@tool
class_name LevelSceneRandomizationBinding
extends Resource


@export var source_scene: PackedScene:
	set(value):
		source_scene = value
		if !value or value.resource_path.is_empty():
			resource_name = "Scene"
			return
		resource_name = value.resource_path.get_file()
@export var targets: Array[LevelTargetRandomizationBinding] = []


func _init() -> void:
	resource_name = "Scene"


func matches(scene_path: String) -> bool:
	return source_scene  and source_scene.resource_path == scene_path


func get_authored_state(target_binding: LevelTargetRandomizationBinding) -> TransformRandomizationState:
	if !source_scene:
		return null

	var source_root: Node3D = source_scene.instantiate() as Node3D
	if !source_root:
		return null

	var target: Node3D = target_binding.get_target(source_root)
	if !target:
		source_root.free()
		return null

	var state: TransformRandomizationState = TransformRandomizationState.new(target.position, target.rotation)
	source_root.free()
	return state
