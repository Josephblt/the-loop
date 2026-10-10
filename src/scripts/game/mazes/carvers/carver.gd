@abstract 
class_name Carver
	

var randomizer: RandomNumberGenerator


@abstract 
func _carve_maze(maze: Maze) -> void


func _init(session_seed: int) -> void:
	randomizer = RandomNumberGenerator.new()
	randomizer.seed = session_seed


func _carve_inner_gates(maze: Maze) -> void:
	var cell_top_gate: Cell = maze.grid[maze.center][maze.spawn_start - 1]
	cell_top_gate.cell_type = Cell.CellType.GATE
	var wall_top_gate: Wall = cell_top_gate.walls[Wall.WallDirection.SOUTH]
	wall_top_gate.type = Wall.WallType.GATE_WALL

	var cell_bottom_gate: Cell = maze.grid[maze.center][maze.spawn_end + 1]
	cell_bottom_gate.cell_type = Cell.CellType.GATE
	var wall_bottom_gate: Wall = cell_bottom_gate.walls[Wall.WallDirection.NORTH]
	wall_bottom_gate.type = Wall.WallType.GATE_WALL

	var cell_left_gate: Cell = maze.grid[maze.spawn_start - 1][maze.center]
	cell_left_gate.cell_type = Cell.CellType.GATE
	var wall_left_gate: Wall = cell_left_gate.walls[Wall.WallDirection.EAST]
	wall_left_gate.type = Wall.WallType.GATE_WALL

	var cell_right_gate: Cell = maze.grid[maze.spawn_end + 1][maze.center]
	cell_right_gate.cell_type = Cell.CellType.GATE
	var wall_right_gate: Wall = cell_right_gate.walls[Wall.WallDirection.WEST]
	wall_right_gate.type = Wall.WallType.GATE_WALL


func _carve_outer_gates(maze: Maze) -> void:
	var cell_top_gate: Cell = maze.grid[maze.center][0]
	cell_top_gate.cell_type = Cell.CellType.GATE
	var wall_top_gate: Wall = cell_top_gate.walls[Wall.WallDirection.NORTH]
	wall_top_gate.type = Wall.WallType.GATE_WALL

	var cell_bottom_gate: Cell = maze.grid[maze.center][maze.grid_size - 1]
	cell_bottom_gate.cell_type = Cell.CellType.GATE
	var wall_bottom_gate: Wall = cell_bottom_gate.walls[Wall.WallDirection.SOUTH]
	wall_bottom_gate.type = Wall.WallType.GATE_WALL

	var cell_left_gate: Cell = maze.grid[0][maze.center]
	cell_left_gate.cell_type = Cell.CellType.GATE
	var wall_left_gate: Wall = cell_left_gate.walls[Wall.WallDirection.WEST]
	wall_left_gate.type = Wall.WallType.GATE_WALL

	var cell_right_gate: Cell = maze.grid[maze.grid_size - 1][maze.center]
	cell_right_gate.cell_type = Cell.CellType.GATE
	var wall_right_gate: Wall = cell_right_gate.walls[Wall.WallDirection.EAST]
	wall_right_gate.type = Wall.WallType.GATE_WALL


func _carve_memories(maze: Maze) -> void:
	var gate_positions: Array[Vector2i] = _get_gate_positions(maze)

	var candidates: Array[Vector2i] = []
	for x in maze.grid_size:
		for y in maze.grid_size:
			var cell: Cell = maze.grid[x][y]
			if cell != null and cell.cell_type == Cell.CellType.MAZE:
				if not _is_adjacent_to_gate(Vector2i(x, y), gate_positions):
					candidates.append(Vector2i(x, y))

	ArrayRandomizer.shuffle(candidates, randomizer)

	var memory_count: int = maze.grid_size
	var chosen: Array[Vector2i] = []
	var remaining: Array[Vector2i] = []

	for pos in candidates:
		if chosen.size() >= memory_count:
			break

		var too_close := false
		for other in chosen:
			if abs(pos.x - other.x) <= 1 and abs(pos.y - other.y) <= 1:
				too_close = true
				break

		if not too_close:
			chosen.append(pos)
		else:
			remaining.append(pos)

	for pos in remaining:
		if chosen.size() >= memory_count:
			break
		chosen.append(pos)

	var directions: Array = Wall.WallDirection.values()
	for pos in chosen:
		var cell: Cell = maze.grid[pos.x][pos.y]
		cell.cell_type = Cell.CellType.MEMORY
		var eligible: Array = directions.filter(func(dir): return cell.walls[dir].type != Wall.WallType.BORDER_WALL)
		var gate_direction: Wall.WallDirection = eligible[randomizer.randi_range(0, eligible.size() - 1)]
		for dir in eligible:
			if dir == gate_direction:
				cell.walls[dir].type = Wall.WallType.MEMORY_GATE
			else:
				cell.walls[dir].type = Wall.WallType.MEMORY_WALL


func _get_gate_positions(maze: Maze) -> Array[Vector2i]:
	var gates: Array[Vector2i] = []
	for x in maze.grid_size:
		for y in maze.grid_size:
			var cell: Cell = maze.grid[x][y]
			if cell != null and cell.cell_type == Cell.CellType.GATE:
				gates.append(Vector2i(x, y))
	return gates


func _is_adjacent_to_gate(pos: Vector2i, gate_positions: Array[Vector2i]) -> bool:
	for gate in gate_positions:
		if abs(pos.x - gate.x) <= 1 and abs(pos.y - gate.y) <= 1:
			return true
	return false


static func carve(maze: Maze, grief_stage: GriefStagesStack.GriefStages, session_seed: int) -> void:
	var carver: Carver

	match grief_stage:
		GriefStagesStack.GriefStages.DENIAL:
			carver = DenialCarver.new(session_seed)

	carver._carve_inner_gates(maze)
	carver._carve_outer_gates(maze)
	carver._carve_memories(maze)
	carver._carve_maze(maze)