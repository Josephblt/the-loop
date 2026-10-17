@tool
class_name LevelRandomizationEntry
extends RefCounted


var node: Node3D
var binding: LevelSceneRandomizationBinding
var target_binding: LevelTargetRandomizationBinding


func _init(randomizable_node: Node3D, randomization_binding: LevelSceneRandomizationBinding, randomization_target_binding: LevelTargetRandomizationBinding) -> void:
	node = randomizable_node
	binding = randomization_binding
	target_binding = randomization_target_binding
