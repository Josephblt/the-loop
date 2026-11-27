class_name StageLayout
extends Resource

const CELL_SIZE: float = 5.6
const ENEMY_HEIGHT: float = 2.6

@export var maze_size: int = 71
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

var _maze_enemy_transform: Transform3D
var maze_enemy_transform: Transform3D:
	get:
		return _maze_enemy_transform


func initialize(new_session_seed: int, memories_per_stage: int, loop_count: int, grief_stage: GriefStagesStack.GriefStages) -> void:
	_session_seed = new_session_seed
	_memory_room_count = memories_per_stage
	var stage_seed: int = new_session_seed + loop_count * GriefStagesStack.GriefStages.size() + int(grief_stage)
	_anger_room_transform = _calculate_grief_room_transform(Vector3.BACK)
	_denial_room_transform = _calculate_grief_room_transform(Vector3.FORWARD)
	_bargaining_room_transform = _calculate_grief_room_transform(Vector3.LEFT)
	_depression_room_transform = _calculate_grief_room_transform(Vector3.RIGHT)
	_maze_enemy_transform = _calculate_maze_enemy_transform(grief_stage, stage_seed)
	_memory_room_transforms = _calculate_memory_rooms_transforms()
	_calculate_maze_room_layout(stage_seed, grief_stage)


func _calculate_grief_room_transform(direction: Vector3) -> Transform3D:
	var maze_half_size: int = int(maze_size / 2.0)
	var room_half_size: int = int(grief_room_size / 2.0)
	var room_distance: float = float(maze_half_size + 1 + grief_room_entrance_offset + room_half_size) * CELL_SIZE
	return Transform3D(Basis.IDENTITY, direction * room_distance)


func _calculate_maze_enemy_transform(grief_stage: GriefStagesStack.GriefStages, stage_seed: int) -> Transform3D:
	if grief_stage == GriefStagesStack.GriefStages.ACCEPTANCE:
		var acceptance_transform: Transform3D = _calculate_acceptance_maze_enemy_transform(stage_seed)
		acceptance_transform.origin.y = ENEMY_HEIGHT
		return acceptance_transform
	var room_origin: Vector3 = Vector3.ZERO
	match grief_stage:
		GriefStagesStack.GriefStages.ANGER:
			room_origin = _anger_room_transform.origin
		GriefStagesStack.GriefStages.DENIAL:
			room_origin = _denial_room_transform.origin
		GriefStagesStack.GriefStages.BARGAINING:
			room_origin = _bargaining_room_transform.origin
		GriefStagesStack.GriefStages.DEPRESSION:
			room_origin = _depression_room_transform.origin
	var maze_half_size: int = int(maze_size / 2.0)
	var gate_cell_distance: float = float(maze_half_size) * CELL_SIZE
	var enemy_position: Vector3 = room_origin.normalized() * gate_cell_distance
	enemy_position.y = ENEMY_HEIGHT
	return Transform3D(Basis.IDENTITY, enemy_position)


func _calculate_acceptance_maze_enemy_transform(stage_seed: int) -> Transform3D:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = stage_seed
	var directions: Array[Vector3] = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT]
	var direction: Vector3 = directions[randomizer.randi_range(0, directions.size() - 1)]
	var room_half_size: int = int(acceptance_room_size / 2.0)
	var gate_cell_distance: float = float(room_half_size + spawn_room_entrance_offset + 1) * CELL_SIZE
	return Transform3D(Basis.IDENTITY, direction * gate_cell_distance)


func _calculate_memory_rooms_transforms() -> Array[Transform3D]:
	return MemoryRoomsLayout.new(self).calculate_transforms()


func _calculate_maze_room_layout(maze_seed: int, grief_stage: GriefStagesStack.GriefStages) -> void:
	var maze_room_layout: MazeRoomLayout = MazeRoomLayout.new(self, maze_seed, grief_stage)
	_maze_floor_transforms = maze_room_layout.floor_transforms
	_maze_walls = maze_room_layout.walls
