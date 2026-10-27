class_name Maze
extends RefCounted


var grid_size: int
var cell_size: float
var grid: Array[Array] = []


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


func valid_cells() -> Array[Cell]:
	var cells: Array[Cell] = []
	for column: Array in grid:
		for cell: Cell in column:
			if cell != null:
				cells.append(cell)
	return cells


func cell_world_position(cell: Cell) -> Vector3:
	var center: int = int(grid_size / 2.0)
	return Vector3(
		float(cell.position.x - center) * cell_size,
		0.0,
		float(cell.position.y - center) * cell_size
	)


func _is_excluded(position: Vector2i, excluded_areas: Array[Rect2i], excluded_cells: Array[Vector2i]) -> bool:
	if excluded_cells.has(position):
		return true

	for area: Rect2i in excluded_areas:
		if area.has_point(position):
			return true
	return false
