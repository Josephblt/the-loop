class_name DenialCarver
extends Carver


func _init(session_seed: int) -> void:
	super._init(session_seed)


func _carve_maze(maze: Maze) -> void:
	var starting_points: Array[Vector2i] = _get_starting_points(maze)

	var visited: Dictionary = {}
	var frontier: Array = []

	for pos in starting_points:
		visited[pos] = true
		_add_frontier(maze, pos, frontier, visited)

	while frontier.size() > 0:
		var index: int = randomizer.randi_range(0, frontier.size() - 1)
		var entry: Dictionary = frontier[index]
		frontier.remove_at(index)

		var target: Vector2i = entry["target"]
		if visited.has(target):
			continue

		visited[target] = true
		var source: Vector2i = entry["source"]
		var direction: Wall.WallDirection = entry["direction"]
		maze.grid[source.x][source.y].walls[direction].type = Wall.WallType.NONE

		_add_frontier(maze, target, frontier, visited)

	for x in maze.grid_size:
		for y in maze.grid_size:
			var cell: Cell = maze.grid[x][y]
			if cell == null or cell.cell_type == Cell.CellType.MEMORY:
				continue
			for dir in Wall.WallDirection.values():
				var wall: Wall = cell.walls[dir]
				if wall.type != Wall.WallType.MAZE_WALL:
					continue
				var neighbor_pos: Vector2i = _get_neighbor_pos(Vector2i(x, y), dir)
				if _is_in_bounds(maze, neighbor_pos):
					var neighbor: Cell = maze.grid[neighbor_pos.x][neighbor_pos.y]
					if neighbor != null and neighbor.cell_type == Cell.CellType.MEMORY:
						continue
				if randomizer.randf() < 0.1:
					wall.type = Wall.WallType.NONE


func _get_starting_points(maze: Maze) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	for x in maze.grid_size:
		for y in maze.grid_size:
			var cell: Cell = maze.grid[x][y]
			if cell != null and (cell.cell_type == Cell.CellType.GATE or cell.cell_type == Cell.CellType.MEMORY):
				points.append(Vector2i(x, y))
	return points


func _add_frontier(maze: Maze, pos: Vector2i, frontier: Array, visited: Dictionary) -> void:
	var source_cell: Cell = maze.grid[pos.x][pos.y]
	if source_cell.cell_type == Cell.CellType.MEMORY:
		return

	for direction in Wall.WallDirection.values():
		var neighbor: Vector2i = _get_neighbor_pos(pos, direction)
		if visited.has(neighbor):
			continue
		if neighbor.x < 0 or neighbor.x >= maze.grid_size or neighbor.y < 0 or neighbor.y >= maze.grid_size:
			continue
		var neighbor_cell: Cell = maze.grid[neighbor.x][neighbor.y]
		if neighbor_cell == null or neighbor_cell.cell_type == Cell.CellType.MEMORY:
			continue
		var wall: Wall = source_cell.walls[direction]
		if wall.type != Wall.WallType.MAZE_WALL:
			continue
		frontier.append({"source": pos, "target": neighbor, "direction": direction})


func _get_neighbor_pos(pos: Vector2i, direction: Wall.WallDirection) -> Vector2i:
	match direction:
		Wall.WallDirection.NORTH:
			return Vector2i(pos.x, pos.y - 1)
		Wall.WallDirection.SOUTH:
			return Vector2i(pos.x, pos.y + 1)
		Wall.WallDirection.EAST:
			return Vector2i(pos.x + 1, pos.y)
		Wall.WallDirection.WEST:
			return Vector2i(pos.x - 1, pos.y)
		_:
			return pos


func _is_in_bounds(maze: Maze, pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < maze.grid_size and pos.y >= 0 and pos.y < maze.grid_size