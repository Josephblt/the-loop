@tool
class_name RandomizationCatalog
extends Resource


@export var bindings: Array[SceneRandomizationBinding] = []


func find_binding(scene_instance: Node3D) -> SceneRandomizationBinding:
	var scene_path: String = scene_instance.scene_file_path
	if scene_path.is_empty():
		return null

	for binding: SceneRandomizationBinding in bindings:
		if binding and binding.matches(scene_path):
			return binding

	return null


func find_source_scene(target: TargetRandomizationBinding) -> PackedScene:
	for binding: SceneRandomizationBinding in bindings:
		if binding and target in binding.targets:
			return binding.source_scene

	return null
