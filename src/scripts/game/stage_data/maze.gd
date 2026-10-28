class_name Maze
extends RefCounted


var grid_size: int
var cell_size: float
var grid: Array[Array] = []
var horizontal_walls: Array[Array] = []
var vertical_walls: Array[Array] = []
var walls: Array[Wall] = []


func _init(size: int, spacing: float, excluded_areas: Array[Rect2i], excluded_cells: Array[Vector2i]) -> void:
	grid_size = size
	cell_size = spacing

	for x: int in range(grid_size):
		var column: Array[Cell] = []
		for y: int in range(grid_size):
			var position: Vector2i = Vector2i(x, y)
			if _is_excluded(position, excluded_areas, excluded_cells):
				column.append(null)
			else:
				column.append(Cell.new(position))
		grid.append(column)

	_create_wall_grids()
	_create_border_walls()


func valid_cells() -> Array[Cell]:
	var cells: Array[Cell] = []
	for column: Array in grid:
		for cell: Cell in column:
			if cell != null:
				cells.append(cell)
	return cells


func cell_world_position(cell: Cell) -> Vector3:
	return _grid_world_position(cell.position)


func wall_world_transform(wall: Wall) -> Transform3D:
	var cell_position: Vector2i
	var rotation: float

	if wall.axis == Wall.WallAxis.HORIZONTAL:
		cell_position = Vector2i(wall.position.x, 0)
		if wall.position.y == grid_size:
			cell_position.y = grid_size - 1
			rotation = PI
	else:
		cell_position = Vector2i(0, wall.position.y)
		rotation = PI / 2.0
		if wall.position.x == grid_size:
			cell_position.x = grid_size - 1
			rotation = -PI / 2.0

	return Transform3D(Basis(Vector3.UP, rotation), _grid_world_position(cell_position))


func _grid_world_position(position: Vector2i) -> Vector3:
	var center: int = int(grid_size / 2.0)
	return Vector3(
		float(position.x - center) * cell_size,
		0.0,
		float(position.y - center) * cell_size
	)


func _create_wall_grids() -> void:
	for _x: int in range(grid_size):
		var horizontal_column: Array[Wall] = []
		horizontal_column.resize(grid_size + 1)
		horizontal_walls.append(horizontal_column)

	for _x: int in range(grid_size + 1):
		var vertical_column: Array[Wall] = []
		vertical_column.resize(grid_size)
		vertical_walls.append(vertical_column)


func _create_border_walls() -> void:
	var last_cell: int = grid_size - 1
	for x: int in range(grid_size):
		if grid[x][0] != null:
			_add_wall(horizontal_walls, Vector2i(x, 0), Wall.WallAxis.HORIZONTAL)
		if grid[x][last_cell] != null:
			_add_wall(horizontal_walls, Vector2i(x, grid_size), Wall.WallAxis.HORIZONTAL)

	for y: int in range(grid_size):
		if grid[0][y] != null:
			_add_wall(vertical_walls, Vector2i(0, y), Wall.WallAxis.VERTICAL)
		if grid[last_cell][y] != null:
			_add_wall(vertical_walls, Vector2i(grid_size, y), Wall.WallAxis.VERTICAL)


func _add_wall(wall_grid: Array[Array], position: Vector2i, axis: Wall.WallAxis) -> void:
	var wall: Wall = Wall.new(Wall.WallType.BORDER, axis, position)
	wall_grid[position.x][position.y] = wall
	walls.append(wall)


func _is_excluded(position: Vector2i, excluded_areas: Array[Rect2i], excluded_cells: Array[Vector2i]) -> bool:
	if excluded_cells.has(position):
		return true

	for area: Rect2i in excluded_areas:
		if area.has_point(position):
			return true
	return false
