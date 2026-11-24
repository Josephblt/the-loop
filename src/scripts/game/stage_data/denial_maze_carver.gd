class_name DenialMazeCarver


var _cells: Dictionary = {}
var _open_edges: Dictionary = {}
var _randomizer: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(floor_cells: Array[Vector2i], maze_seed: int) -> void:
	_randomizer.seed = maze_seed
	for cell: Vector2i in floor_cells:
		_cells[cell] = true
	_carve_paths(floor_cells)
	_connect_dead_ends(floor_cells)
	_add_loops(floor_cells)


func has_passage(cell: Vector2i, neighbour: Vector2i) -> bool:
	return _open_edges.has(_edge(cell, neighbour))


func _carve_paths(floor_cells: Array[Vector2i]) -> void:
	var visited: Dictionary = {}
	for start: Vector2i in floor_cells:
		if visited.has(start):
			continue
		var stack: Array[Vector2i] = [start]
		visited[start] = true
		while not stack.is_empty():
			var cell: Vector2i = stack.back()
			var candidates: Array[Vector2i] = []
			for neighbour: Vector2i in _neighbours(cell):
				if not visited.has(neighbour):
					candidates.append(neighbour)
			if candidates.is_empty():
				stack.pop_back()
				continue
			var next_cell: Vector2i = candidates[_randomizer.randi_range(0, candidates.size() - 1)]
			_open_edges[_edge(cell, next_cell)] = true
			visited[next_cell] = true
			stack.append(next_cell)


func _connect_dead_ends(floor_cells: Array[Vector2i]) -> void:
	for cell: Vector2i in floor_cells:
		var neighbours: Array[Vector2i] = _neighbours(cell)
		var open_count: int = 0
		var closed: Array[Vector2i] = []
		for neighbour: Vector2i in neighbours:
			if has_passage(cell, neighbour):
				open_count += 1
			else:
				closed.append(neighbour)
		if open_count >= 2 or closed.is_empty():
			continue
		var next_cell: Vector2i = closed[_randomizer.randi_range(0, closed.size() - 1)]
		_open_edges[_edge(cell, next_cell)] = true


func _add_loops(floor_cells: Array[Vector2i]) -> void:
	for cell: Vector2i in floor_cells:
		for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
			var neighbour: Vector2i = cell + direction
			if _cells.has(neighbour) and not has_passage(cell, neighbour) and _randomizer.randf() < 0.18:
				_open_edges[_edge(cell, neighbour)] = true


func _neighbours(cell: Vector2i) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for direction: Vector2i in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		var neighbour: Vector2i = cell + direction
		if _cells.has(neighbour):
			neighbours.append(neighbour)
	return neighbours


func _edge(cell: Vector2i, neighbour: Vector2i) -> Vector4i:
	if neighbour.x < cell.x or (neighbour.x == cell.x and neighbour.y < cell.y):
		return Vector4i(neighbour.x, neighbour.y, cell.x, cell.y)
	return Vector4i(cell.x, cell.y, neighbour.x, neighbour.y)
