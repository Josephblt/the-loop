@tool
class_name LevelRandomizationState
extends RefCounted


var position: Vector3
var rotation: Vector3


func _init(
	randomized_position: Vector3,
	randomized_rotation: Vector3
) -> void:
	position = randomized_position
	rotation = randomized_rotation
