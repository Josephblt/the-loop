class_name MazeWall
extends RefCounted


enum WallType {
	BROKEN,
	NORMAL,
}

enum WallSize {
	SMALL,
	MEDIUM,
	LARGE,
}

var transform: Transform3D
var wall_type: WallType
var wall_size: WallSize
var stack_count: int
var cell: Vector2i
var neighbour: Vector2i


func _init(initial_transform: Transform3D, initial_type: WallType, initial_size: WallSize, initial_stack_count: int) -> void:
	transform = initial_transform
	wall_type = initial_type
	wall_size = initial_size
	stack_count = initial_stack_count