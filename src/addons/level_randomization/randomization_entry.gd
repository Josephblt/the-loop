@tool
class_name RandomizationEntry


var node: Node3D
var binding: SceneRandomizationBinding
var target_binding: TargetRandomizationBinding


func _init(randomizable_node: Node3D, randomization_binding: SceneRandomizationBinding, randomization_target_binding: TargetRandomizationBinding) -> void:
	node = randomizable_node
	binding = randomization_binding
	target_binding = randomization_target_binding
