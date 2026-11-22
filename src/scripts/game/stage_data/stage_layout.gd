class_name StageLayout
extends Resource

@export var cell_size: float = 5.6
@export var maze_size: int = 31
@export var grief_room_size: int = 7
@export var grief_room_entrance_offset: int = 2
@export var spawn_room_size: int = 3
@export var spawn_room_entrance_offset: int = 2
@export var memory_room_size: int = 3

var session_seed: int:
	get:
		return _session_seed

var memory_room_count: int:
	get:
		return _memory_room_count

var anger_room_transform: Transform3D:
	get:
		return _anger_room_transform

var denial_room_transform: Transform3D:
	get:
		return _denial_room_transform

var bargaining_room_transform: Transform3D:
	get:
		return _bargaining_room_transform

var depression_room_transform: Transform3D:
	get:
		return _depression_room_transform

var memory_room_transforms: Array[Transform3D]:
	get:
		return _memory_room_transforms

var _anger_room_transform: Transform3D
var _bargaining_room_transform: Transform3D
var _denial_room_transform: Transform3D
var _depression_room_transform: Transform3D
var _memory_room_count: int
var _memory_room_transforms: Array[Transform3D]
var _session_seed: int


func initialize(new_session_seed: int, new_memory_room_count: int) -> void:
	_session_seed = new_session_seed
	_memory_room_count = new_memory_room_count
	_anger_room_transform = _calculate_grief_room_transform(Vector3.BACK)
	_denial_room_transform = _calculate_grief_room_transform(Vector3.FORWARD)
	_bargaining_room_transform = _calculate_grief_room_transform(Vector3.LEFT)
	_depression_room_transform = _calculate_grief_room_transform(Vector3.RIGHT)
	_memory_room_transforms = MemoryRoomsLayout.new(self).calculate_transforms()


func _calculate_grief_room_transform(direction: Vector3) -> Transform3D:
	var maze_half_size: int = int(maze_size / 2.0)
	var room_half_size: int = int(grief_room_size / 2.0)
	var room_distance: float = float(maze_half_size + 1 + grief_room_entrance_offset + room_half_size) * cell_size
	return Transform3D(Basis.IDENTITY, direction * room_distance)
