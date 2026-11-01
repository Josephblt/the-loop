class_name StageLayout
extends Resource

@export var cell_size: float = 5.6
@export var spawn_room_size: int = 7
@export var maze_size: int = 21
@export var grief_room_entrance_offset: int = 5

@export var stories: Array[Story] = []

var spawn_north_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.FORWARD, PI)

var spawn_south_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.BACK, 0.0)

var spawn_west_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.LEFT, PI)

var spawn_east_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.RIGHT, 0.0)

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


func _spawn_gate_transform(direction: Vector3, rotation: float) -> Transform3D:
	var room_half_size: int = int(spawn_room_size / 2.0)
	var gate_distance: float = float(room_half_size + 1) * cell_size
	return Transform3D(Basis(Vector3.UP, rotation), direction * gate_distance)


func _grief_room_transform(direction: Vector3) -> Transform3D:
	var maze_half_size: int = int(maze_size / 2.0)
	var room_distance: float = float(maze_half_size + 1 + grief_room_entrance_offset) * cell_size
	return Transform3D(Basis.IDENTITY, direction * room_distance)
