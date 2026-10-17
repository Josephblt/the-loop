@tool
class_name LevelTargetRandomizationBinding
extends Resource


@export var target_path: NodePath = ^"MeshInstance3D":
	set(value):
		target_path = value
		resource_name = str(value) if !value.is_empty() else "Target"
@export var profile: TransformRandomizationProfile


func _init() -> void:
	resource_name = str(target_path)


func get_target(scene_instance: Node3D) -> Node3D:
	return scene_instance.get_node_or_null(target_path) as Node3D
