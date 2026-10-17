@tool
class_name LevelTargetRandomizationBinding
extends Resource


@export var target_path: NodePath = ^"MeshInstance3D"
@export var profile: TransformRandomizationProfile


func get_target(scene_instance: Node3D) -> Node3D:
	return scene_instance.get_node_or_null(target_path) as Node3D
