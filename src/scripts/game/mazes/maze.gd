class_name Maze


var grid: Array[Array]

var grid_size: int
var spawn_size: int
var center: int
var spawn_center: int
var spawn_start: int
var spawn_end: int


func _init(session_grief_stage: GriefStagesStack.GriefStages, 
		   session_seed: int,
		   session_grid_size: int,
		   session_spawn_size: int) -> void:

	grid_size = session_grid_size
	spawn_size = session_spawn_size
	center = int(grid_size / 2.0)
	spawn_center = int(spawn_size / 2.0)
	spawn_start = center - spawn_center
	spawn_end = center + spawn_center

	grid = []
	for x in grid_size:
		grid.append([])
		for y in grid_size:
			if _is_maze_area(x, y):
				var cell: Cell = _create_cell()
				grid[x].append(cell)
			else:
				grid[x].append(null)
	
	for x in grid_size:
		for y in grid_size:
			var cell: Cell = grid[x][y]
			if cell:
				_create_walls(x, y, cell)
			
	Carver.carve(self, session_grief_stage, session_seed)
	

func _is_maze_area(x: int, y: int) -> bool:	
	return (x < spawn_start or x > spawn_end or y < spawn_start or y > spawn_end)


func _fetch_neighbor_cell(x: int, y: int, wall_direction: Wall.WallDirection) -> Cell:
	match wall_direction:
		Wall.WallDirection.NORTH:
			if y == 0:
				return null
			return grid[x][y - 1]
		Wall.WallDirection.SOUTH:
			if y == grid_size - 1:
				return null
			return grid[x][y + 1]
		Wall.WallDirection.EAST:
			if x == grid_size - 1:
				return null
			return grid[x + 1][y]
		Wall.WallDirection.WEST:
			if x == 0:
				return null
			return grid[x - 1][y]
		_:
			return null


func _create_cell() -> Cell:
	var cell: Cell = Cell.new()		
	cell.cell_type = Cell.CellType.MAZE
	return cell


func _create_walls(x: int, y: int, cell: Cell) -> void:
	for wall_direction in Wall.WallDirection.values():
		if cell.walls[wall_direction]:
			continue

		var wall: Wall = Wall.new()
		wall.direction = wall_direction
		wall.type = Wall.WallType.MAZE_WALL
		cell.walls[wall_direction] = wall
		
		var neighbor_cell: Cell = _fetch_neighbor_cell(x, y, wall_direction)
		if neighbor_cell:
			neighbor_cell.walls[Wall.opposite(wall_direction)] = wall
		else:
			wall.type = Wall.WallType.BORDER_WALL