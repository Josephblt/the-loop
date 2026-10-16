@tool
class_name LevelRandomizationEntry
extends RefCounted


var node: Node3D
var rule: LevelRandomizationRule


func _init(
	randomizable_node: Node3D,
	randomization_rule: LevelRandomizationRule
) -> void:
	node = randomizable_node
	rule = randomization_rule
