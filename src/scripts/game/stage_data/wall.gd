class_name Wall
extends RefCounted


enum WallType {
	BORDER,
}

enum WallAxis {
	HORIZONTAL,
	VERTICAL,
}

var wall_type: WallType
var axis: WallAxis
var position: Vector2i


func _init(initial_type: WallType, wall_axis: WallAxis, wall_position: Vector2i) -> void:
	wall_type = initial_type
	axis = wall_axis
	position = wall_position
