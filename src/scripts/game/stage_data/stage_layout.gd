class_name StageLayout
extends Resource

@export var cell_size: float = 5.6
@export var maze_size: int = 31
@export var grief_room_size: int = 7
@export var grief_room_entrance_offset: int = 2
@export var spawn_room_size: int = 3
@export var spawn_room_entrance_offset: int = 2
@export var memory_room_size: int = 3

var session_seed: int

var anger_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.BACK)

var denial_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.FORWARD)

var bargaining_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.LEFT)

var depression_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.RIGHT)

var memory_room_transforms: Array[Transform3D]:
	get:
		return _memory_rooms_transforms()



func _grief_room_transform(direction: Vector3) -> Transform3D:
	var maze_half_size: int = int(maze_size / 2.0)
	var room_half_size: int = int(grief_room_size / 2.0)
	var room_distance: float = float(maze_half_size + 1 + grief_room_entrance_offset + room_half_size) * cell_size
	return Transform3D(Basis.IDENTITY, direction * room_distance)


func _memory_rooms_transforms() -> Array[Transform3D]:
	return MemoryRoomsLayout.new(self).calculate_transforms()