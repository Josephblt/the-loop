class_name StageLayout
extends Resource

@export var cell_size: float = 5.6
@export var maze_size: int = 31
@export var grief_room_size: int = 7
@export var grief_room_entrance_offset: int = 2
@export var acceptance_room_size: int = 3
@export var spawn_room_entrance_offset: int = 2
@export var memory_room_size: int = 3


var _session_seed: int
var session_seed: int:
	get:
		return _session_seed

var _memory_room_count: int
var memory_room_count: int:
	get:
		return _memory_room_count

var _anger_room_transform: Transform3D
var anger_room_transform: Transform3D:
	get:
		return _anger_room_transform

var _bargaining_room_transform: Transform3D
var bargaining_room_transform: Transform3D:
	get:
		return _bargaining_room_transform

var _denial_room_transform: Transform3D
var denial_room_transform: Transform3D:
	get:
		return _denial_room_transform

var _depression_room_transform: Transform3D
var depression_room_transform: Transform3D:
	get:
		return _depression_room_transform

var _memory_room_transforms: Array[Transform3D]
var memory_room_transforms: Array[Transform3D]:
	get:
		return _memory_room_transforms

var _maze_floor_transforms: Array[Transform3D]
var maze_floor_transforms: Array[Transform3D]:
	get:
		return _maze_floor_transforms

var _maze_walls: Array[MazeWall]
var maze_walls: Array[MazeWall]:
	get:
		return _maze_walls


func initialize(new_session_seed: int, memories_per_stage: int) -> void:
	_session_seed = new_session_seed
	_memory_room_count = memories_per_stage
	_anger_room_transform = _calculate_grief_room_transform(Vector3.BACK)
	_denial_room_transform = _calculate_grief_room_transform(Vector3.FORWARD)
	_bargaining_room_transform = _calculate_grief_room_transform(Vector3.LEFT)
	_depression_room_transform = _calculate_grief_room_transform(Vector3.RIGHT)
	_memory_room_transforms = _calculate_memory_rooms_transforms()
	_calculate_maze_room_layout()


func _calculate_grief_room_transform(direction: Vector3) -> Transform3D:
	var maze_half_size: int = int(maze_size / 2.0)
	var room_half_size: int = int(grief_room_size / 2.0)
	var room_distance: float = float(maze_half_size + 1 + grief_room_entrance_offset + room_half_size) * cell_size
	return Transform3D(Basis.IDENTITY, direction * room_distance)


func _calculate_memory_rooms_transforms() -> Array[Transform3D]:
	return MemoryRoomsLayout.new(self).calculate_transforms()


func _calculate_maze_room_layout() -> void:
	var maze_room_layout: MazeRoomLayout = MazeRoomLayout.new(self, false)
	_maze_floor_transforms = maze_room_layout.floor_transforms
	_maze_walls = maze_room_layout.walls
