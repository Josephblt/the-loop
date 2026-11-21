class_name MemoryRoomsLayout


static func calculate_transforms(
	session_seed: int,
	room_count: int,
	cell_size: float,
	maze_size: int,
	spawn_room_size: int,
	memory_room_size: int
) -> Array[Transform3D]:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = session_seed
	var positions: Array[Vector2i] = _room_positions(randomizer, room_count, maze_size, spawn_room_size, memory_room_size)
	var transforms: Array[Transform3D] = []
	var maze_center: int = int(maze_size / 2.0)
	for position: Vector2i in positions:
		var rotation: float = float(randomizer.randi_range(0, 3)) * PI / 2.0
		var offset: Vector2i = position - Vector2i(maze_center, maze_center)
		var world_position: Vector3 = Vector3(float(offset.x) * cell_size, 0.0, float(offset.y) * cell_size)
		transforms.append(Transform3D(Basis(Vector3.UP, rotation), world_position))
	return transforms


static func _room_positions(
	randomizer: RandomNumberGenerator,
	room_count: int,
	maze_size: int,
	spawn_room_size: int,
	memory_room_size: int
) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = _room_candidates(maze_size, spawn_room_size, memory_room_size)
	ArrayRandomizer.shuffle(candidates, randomizer)
	var selected: Array[Vector2i] = []
	while selected.size() < room_count:
		var candidate_index: int = _farthest_room_candidate(candidates, selected, memory_room_size)
		selected.append(candidates.pop_at(candidate_index))
	return selected


static func _room_candidates(maze_size: int, spawn_room_size: int, memory_room_size: int) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var room_half_size: int = int(memory_room_size / 2.0)
	var minimum_center: int = room_half_size + 1
	var maximum_center: int = maze_size - room_half_size - 1
	for x: int in range(minimum_center, maximum_center):
		for y: int in range(minimum_center, maximum_center):
			var position: Vector2i = Vector2i(x, y)
			if _room_is_available(position, maze_size, spawn_room_size, memory_room_size):
				candidates.append(position)
	return candidates


static func _room_is_available(position: Vector2i, maze_size: int, spawn_room_size: int, memory_room_size: int) -> bool:
	var bounds: Rect2i = _room_bounds(position, memory_room_size)
	if bounds.intersects(_spawn_room_border(maze_size, spawn_room_size)):
		return false
	for approach: Rect2i in _gate_approaches(maze_size, spawn_room_size, memory_room_size):
		if bounds.intersects(approach):
			return false
	return true


static func _farthest_room_candidate(candidates: Array[Vector2i], selected: Array[Vector2i], memory_room_size: int) -> int:
	var farthest_index: int = -1
	var farthest_distance: int = -1
	for index: int in candidates.size():
		var candidate: Vector2i = candidates[index]
		if _overlaps_room(candidate, selected, memory_room_size):
			continue
		var distance: int = _minimum_squared_distance(candidate, selected)
		if distance <= farthest_distance:
			continue
		farthest_distance = distance
		farthest_index = index
	assert(farthest_index >= 0, "Unable to place all memory rooms")
	return farthest_index


static func _overlaps_room(candidate: Vector2i, selected: Array[Vector2i], memory_room_size: int) -> bool:
	var bounds: Rect2i = _room_bounds(candidate, memory_room_size)
	for position: Vector2i in selected:
		if bounds.intersects(_room_bounds(position, memory_room_size)):
			return true
	return false


static func _minimum_squared_distance(candidate: Vector2i, positions: Array[Vector2i]) -> int:
	if positions.is_empty():
		return 0
	var minimum_distance: int = 2_147_483_647
	for position: Vector2i in positions:
		minimum_distance = mini(minimum_distance, (candidate - position).length_squared())
	return minimum_distance


static func _room_bounds(position: Vector2i, memory_room_size: int) -> Rect2i:
	var room_half_size: int = int(memory_room_size / 2.0)
	var offset: Vector2i = Vector2i(room_half_size, room_half_size)
	return Rect2i(position - offset, Vector2i(memory_room_size, memory_room_size))


static func _spawn_room_border(maze_size: int, spawn_room_size: int) -> Rect2i:
	var maze_center: int = int(maze_size / 2.0)
	var room_half_size: int = int(spawn_room_size / 2.0)
	var start: Vector2i = Vector2i(maze_center - room_half_size - 1, maze_center - room_half_size - 1)
	return Rect2i(start, Vector2i(spawn_room_size + 2, spawn_room_size + 2))


static func _gate_approaches(maze_size: int, spawn_room_size: int, memory_room_size: int) -> Array[Rect2i]:
	var maze_center: int = int(maze_size / 2.0)
	var memory_room_half_size: int = int(memory_room_size / 2.0)
	var spawn_room_half_size: int = int(spawn_room_size / 2.0)
	var approach_offset: int = maze_center - memory_room_half_size
	var approach_length: int = maze_center - spawn_room_half_size
	var far_approach_start: int = maze_center + spawn_room_half_size + 1
	return [
		Rect2i(approach_offset, 0, memory_room_size, approach_length),
		Rect2i(approach_offset, far_approach_start, memory_room_size, approach_length),
		Rect2i(0, approach_offset, approach_length, memory_room_size),
		Rect2i(far_approach_start, approach_offset, approach_length, memory_room_size),
	]
