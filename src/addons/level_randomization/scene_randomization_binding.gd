@tool
class_name SceneRandomizationBinding
extends Resource


@export var source_scene: PackedScene:
	set(value):
		source_scene = value
		if !value or value.resource_path.is_empty():
			resource_name = "Scene"
			return
		resource_name = value.resource_path.get_file()
@export var targets: Array[TargetRandomizationBinding] = []


func _init() -> void:
	resource_name = "Scene"


func matches(scene_path: String) -> bool:
	return source_scene  and source_scene.resource_path == scene_path
