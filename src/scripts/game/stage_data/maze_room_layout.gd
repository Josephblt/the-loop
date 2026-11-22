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
var _stage_layout: StageLayout


func _init(stage_layout: StageLayout) -> void:
	_stage_layout = stage_layout
	_reserve_room_cells()
	_reserve_gate_outside_cells()
	_calculate_floor_transforms()
	_calculate_walls()


func _reserve_room_cells() -> void:
	var center: int = int(_stage_layout.maze_size / 2.0)
	_reserve_area(Vector2i(center, center), _stage_layout.grief_room_size)
	for room_transform: Transform3D in _stage_layout.memory_room_transforms:
		var room_center: Vector2i = _world_to_cell(room_transform.origin)
		_reserve_area(room_center, _stage_layout.memory_room_size)


func _reserve_area(center: Vector2i, size: int) -> void:
	var half_size: int = int(size / 2.0)
	for x: int in range(center.x - half_size, center.x + half_size + 1):
		for y: int in range(center.y - half_size, center.y + half_size + 1):
			_reserved_cells[Vector2i(x, y)] = true


func _reserve_gate_outside_cells() -> void:
	var center: int = int(_stage_layout.maze_size / 2.0)
	var last_cell: int = _stage_layout.maze_size - 1
	var inner_offset: int = int(_stage_layout.grief_room_size / 2.0) + 1
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


func _calculate_floor_transforms() -> void:
	for x: int in _stage_layout.maze_size:
		for y: int in _stage_layout.maze_size:
			var cell: Vector2i = Vector2i(x, y)
			if _is_reserved(cell):
				continue
			_floor_transforms.append(Transform3D(Basis.IDENTITY, _cell_world_position(cell)))


func _calculate_walls() -> void:
	for x: int in _stage_layout.maze_size:
		for y: int in _stage_layout.maze_size:
			var cell: Vector2i = Vector2i(x, y)
			if cell.y == 0:
				_add_wall(cell, Vector2i.UP)
			if cell.x == 0:
				_add_wall(cell, Vector2i.LEFT)
			_add_wall(cell, Vector2i.RIGHT)
			_add_wall(cell, Vector2i.DOWN)


func _add_wall(cell: Vector2i, direction: Vector2i) -> void:
	var neighbour: Vector2i = cell + direction
	if _is_reserved(cell) or (_is_inside(neighbour) and _is_reserved(neighbour)):
		return
	var stack_count: int = 1
	if not _is_inside(neighbour):
		stack_count = 2
	_walls.append(MazeWall.new(_wall_transform(cell, direction), MazeWall.WallType.NORMAL, MazeWall.WallSize.LARGE, stack_count))


func _wall_transform(cell: Vector2i, direction: Vector2i) -> Transform3D:
	var half_cell_size: float = _stage_layout.cell_size / 2.0
	var position: Vector3 = _cell_world_position(cell)
	var rotation: float = 0.0
	if direction == Vector2i.UP:
		position += Vector3(half_cell_size, 0.0, -half_cell_size)
		rotation = PI / 2.0
	elif direction == Vector2i.RIGHT:
		position += Vector3(half_cell_size, 0.0, half_cell_size)
	elif direction == Vector2i.DOWN:
		position += Vector3(half_cell_size, 0.0, half_cell_size)
		rotation = PI / 2.0
	else:
		position += Vector3(-half_cell_size, 0.0, half_cell_size)
	return Transform3D(Basis(Vector3.UP, rotation), position)


func _world_to_cell(position: Vector3) -> Vector2i:
	var center: int = int(_stage_layout.maze_size / 2.0)
	return Vector2i(roundi(position.x / _stage_layout.cell_size) + center, roundi(position.z / _stage_layout.cell_size) + center)


func _cell_world_position(cell: Vector2i) -> Vector3:
	var center: int = int(_stage_layout.maze_size / 2.0)
	return Vector3(float(cell.x - center) * _stage_layout.cell_size, 0.0, float(cell.y - center) * _stage_layout.cell_size)


func _is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < _stage_layout.maze_size and cell.y >= 0 and cell.y < _stage_layout.maze_size


func _is_reserved(cell: Vector2i) -> bool:
	return _reserved_cells.has(cell)
