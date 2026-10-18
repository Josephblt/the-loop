@tool
class_name TargetRandomizationBinding
extends Resource


@export var target_path: NodePath
@export var profile: TransformRandomizationProfile


func get_target(scene_instance: Node3D) -> Node3D:
	return scene_instance.get_node_or_null(target_path) as Node3D
