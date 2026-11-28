class_name MazeRoomLayout


var _floor_transforms: Array[Transform3D] = []
var floor_transforms: Array[Transform3D]:
	get:
		return _floor_transforms

var _walls: Array[MazeWall] = []
var walls: Array[MazeWall]:
	get:
		return _walls

var _reserved_cells: Dictionary = {}
var _memory_room_cells: Dictionary = {}
var _memory_room_passages: Dictionary = {}
var _floor_cells: Array[Vector2i] = []
var _stage_layout: StageLayout
var _carver: DenialMazeCarver
var _randomizer: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(stage_layout: StageLayout, maze_seed: int, grief_stage: GriefStagesStack.GriefStages) -> void:
	_stage_layout = stage_layout
	_randomizer.seed = maze_seed
	_reserve_room_cells()
	_reserve_gate_outside_cells()
	_reserve_memory_room_passages()
	_calculate_floor_transforms()
	if grief_stage == GriefStagesStack.GriefStages.DENIAL:
		_carver = DenialMazeCarver.new(_floor_cells, maze_seed)
	_calculate_walls()


func _reserve_room_cells() -> void:
	_reserve_acceptance_room_cells()
	for room_transform: Transform3D in _stage_layout.memory_room_transforms:
		var room_center: Vector2i = _world_to_cell(room_transform.origin)
		_reserve_area(room_center, _stage_layout.memory_room_size)
		var half_size: int = int(_stage_layout.memory_room_size / 2.0)
		for x: int in range(room_center.x - half_size, room_center.x + half_size + 1):
			for y: int in range(room_center.y - half_size, room_center.y + half_size + 1):
				_memory_room_cells[Vector2i(x, y)] = true


func _reserve_acceptance_room_cells() -> void:
	var center: int = int(_stage_layout.maze_size / 2.0)
	var center_cell: Vector2i = Vector2i(center, center)
	var room_half_size: int = int(_stage_layout.acceptance_room_size / 2.0)
	_reserve_area(center_cell, _stage_layout.acceptance_room_size)
	for direction: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		for distance: int in range(room_half_size + 1, room_half_size + _stage_layout.spawn_room_entrance_offset + 1):
			_reserved_cells[center_cell + direction * distance] = true


func _reserve_area(center: Vector2i, size: int) -> void:
	var half_size: int = int(size / 2.0)
	for x: int in range(center.x - half_size, center.x + half_size + 1):
		for y: int in range(center.y - half_size, center.y + half_size + 1):
			_reserved_cells[Vector2i(x, y)] = true


func _reserve_gate_outside_cells() -> void:
	var center: int = int(_stage_layout.maze_size / 2.0)
	var last_cell: int = _stage_layout.maze_size - 1
	var inner_offset: int = int(_stage_layout.acceptance_room_size / 2.0) + _stage_layout.spawn_room_entrance_offset + 1
	var positions: Array[Vector2i] = [
		Vector2i(center, 0),
		Vector2i(center, last_cell),
		Vector2i(0, center),
		Vector2i(last_cell, center),
		Vector2i(center, center - inner_offset),
		Vector2i(center, center + inner_offset),
		Vector2i(center - inner_offset, center),
		Vector2i(center + inner_offset, center),
	]
	for position: Vector2i in positions:
		_reserved_cells[position] = true


func _reserve_memory_room_passages() -> void:
	var half_size: int = int(_stage_layout.memory_room_size / 2.0)
	for room_transform: Transform3D in _stage_layout.memory_room_transforms:
		var center: Vector2i = _world_to_cell(room_transform.origin)
		var stair_direction: Vector3 = room_transform.basis.inverse() * Vector3.BACK
		var direction: Vector2i = Vector2i(roundi(stair_direction.x), roundi(stair_direction.z))
		_memory_room_passages[center + direction * half_size] = center + direction * (half_size + 1)


func _calculate_floor_transforms() -> void:
	for x: int in _stage_layout.maze_size:
		for y: int in _stage_layout.maze_size:
			var cell: Vector2i = Vector2i(x, y)
			if _is_reserved(cell):
				continue
			_floor_cells.append(cell)
			_floor_transforms.append(Transform3D(Basis.IDENTITY, _cell_world_position(cell)))


func _calculate_walls() -> void:
	for cell: Vector2i in _floor_cells:
		if cell.y == 0 or _memory_room_cells.has(cell + Vector2i.UP):
			_add_wall(cell, Vector2i.UP)
		if cell.x == 0 or _memory_room_cells.has(cell + Vector2i.LEFT):
			_add_wall(cell, Vector2i.LEFT)
		if _carver != null or cell.x == _stage_layout.maze_size - 1 or _memory_room_cells.has(cell + Vector2i.RIGHT):
			_add_wall(cell, Vector2i.RIGHT)
		if _carver != null or cell.y == _stage_layout.maze_size - 1 or _memory_room_cells.has(cell + Vector2i.DOWN):
			_add_wall(cell, Vector2i.DOWN)


func _add_wall(cell: Vector2i, direction: Vector2i) -> void:
	var neighbour: Vector2i = cell + direction
	if _is_reserved(cell):
		return
	if _memory_room_cells.has(neighbour) and _memory_room_passages.get(neighbour) == cell:
		return
	if _is_inside(neighbour) and _is_reserved(neighbour) and not _memory_room_cells.has(neighbour):
		return
	if _carver != null and _is_inside(neighbour) and _carver.has_passage(cell, neighbour):
		return

	var stack_count: int = 1
	var wall_size: MazeWall.WallSize = MazeWall.WallSize.LARGE
	if not _is_inside(neighbour):
		stack_count = 2
	else:
		wall_size = MazeWall.WallSize.MEDIUM
		if _carver != null and not _memory_room_cells.has(neighbour) and _randomizer.randf() < 0.12:
			wall_size = MazeWall.WallSize.SMALL

	var wall_type: MazeWall.WallType = MazeWall.WallType.NORMAL
	if _is_inside(neighbour):
		wall_type = MazeWall.WallType.BROKEN
		if wall_size == MazeWall.WallSize.MEDIUM and _carver != null and _randomizer.randf() < 0.5:
			wall_type = MazeWall.WallType.NORMAL

	var wall: MazeWall = MazeWall.new(_wall_transform(cell, direction), wall_type, wall_size, stack_count)
	wall.cell = cell
	wall.neighbour = neighbour
	_walls.append(wall)


func _wall_transform(cell: Vector2i, direction: Vector2i) -> Transform3D:
	var rotation: float = 0.0
	if direction == Vector2i.RIGHT:
		rotation = -PI / 2.0
	elif direction == Vector2i.DOWN:
		rotation = PI
	elif direction == Vector2i.LEFT:
		rotation = PI / 2.0
	return Transform3D(Basis(Vector3.UP, rotation), _cell_world_position(cell))


func _world_to_cell(position: Vector3) -> Vector2i:
	var center: int = int(_stage_layout.maze_size / 2.0)
	return Vector2i(roundi(position.x / _stage_layout.CELL_SIZE) + center, roundi(position.z / _stage_layout.CELL_SIZE) + center)


func _cell_world_position(cell: Vector2i) -> Vector3:
	var center: int = int(_stage_layout.maze_size / 2.0)
	return Vector3(float(cell.x - center) * _stage_layout.CELL_SIZE, 0.0, float(cell.y - center) * _stage_layout.CELL_SIZE)


func _is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < _stage_layout.maze_size and cell.y >= 0 and cell.y < _stage_layout.maze_size


func _is_reserved(cell: Vector2i) -> bool:
	return _reserved_cells.has(cell)