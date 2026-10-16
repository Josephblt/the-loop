@tool
class_name LevelRandomizationEntry
extends RefCounted


var node: Node3D
var binding: LevelSceneRandomizationBinding


func _init(
	randomizable_node: Node3D,
	randomization_binding: LevelSceneRandomizationBinding
) -> void:
	node = randomizable_node
	binding = randomization_binding
