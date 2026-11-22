class_name MemoryRoomsLayout


var _randomizer: RandomNumberGenerator
var _stage_layout: StageLayout


func _init(stage_layout: StageLayout) -> void:
	_stage_layout = stage_layout
	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = stage_layout.session_seed


func calculate_transforms() -> Array[Transform3D]:
	var room_count: int = 5
	var positions: Array[Vector2i] = _room_positions(room_count)
	var room_transforms: Array[Transform3D] = []
	var maze_center: int = int(_stage_layout.maze_size / 2.0)
	
	for position: Vector2i in positions:
		var rotation: float = float(_randomizer.randi_range(0, 3)) * PI / 2.0
		var offset: Vector2i = position - Vector2i(maze_center, maze_center)
		var world_position: Vector3 = Vector3(float(offset.x), 0.0, float(offset.y)) * _stage_layout.cell_size
		room_transforms.append(Transform3D(Basis(Vector3.UP, rotation), world_position))
		
	return room_transforms


func _room_positions(room_count: int) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = _room_candidates()
	ArrayRandomizer.shuffle(candidates, _randomizer)
	var selected: Array[Vector2i] = []
	while selected.size() < room_count:
		var candidate_index: int = _farthest_room_candidate(candidates, selected)
		selected.append(candidates.pop_at(candidate_index))
	return selected


func _room_candidates() -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var room_half_size: int = int(_stage_layout.memory_room_size / 2.0)
	var minimum_center: int = room_half_size + 1
	var maximum_center: int = _stage_layout.maze_size - room_half_size - 1
	for x: int in range(minimum_center, maximum_center):
		for y: int in range(minimum_center, maximum_center):
			var position: Vector2i = Vector2i(x, y)
			if _room_is_available(position):
				candidates.append(position)
	return candidates


func _room_is_available(position: Vector2i) -> bool:
	var bounds: Rect2i = _room_bounds(position)
	if bounds.intersects(_spawn_room_border()):
		return false
	for approach: Rect2i in _gate_approaches():
		if bounds.intersects(approach):
			return false
	return true


func _farthest_room_candidate(candidates: Array[Vector2i], selected: Array[Vector2i]) -> int:
	var farthest_index: int = -1
	var farthest_distance: int = -1
	for index: int in candidates.size():
		var candidate: Vector2i = candidates[index]
		if _overlaps_room(candidate, selected):
			continue
		var distance: int = _minimum_squared_distance(candidate, selected)
		if distance <= farthest_distance:
			continue
		farthest_distance = distance
		farthest_index = index
	assert(farthest_index >= 0, "Unable to place all memory rooms")
	return farthest_index


func _overlaps_room(candidate: Vector2i, selected: Array[Vector2i]) -> bool:
	var bounds: Rect2i = _room_bounds(candidate)
	for position: Vector2i in selected:
		if bounds.intersects(_room_bounds(position)):
			return true
	return false


func _minimum_squared_distance(candidate: Vector2i, positions: Array[Vector2i]) -> int:
	if positions.is_empty():
		return 0
	var minimum_distance: int = 2_147_483_647
	for position: Vector2i in positions:
		minimum_distance = mini(minimum_distance, (candidate - position).length_squared())
	return minimum_distance


func _room_bounds(position: Vector2i) -> Rect2i:
	var room_half_size: int = int(_stage_layout.memory_room_size / 2.0)
	var offset: Vector2i = Vector2i(room_half_size, room_half_size)
	return Rect2i(position - offset, Vector2i(_stage_layout.memory_room_size, _stage_layout.memory_room_size))


func _spawn_room_border() -> Rect2i:
	var maze_center: int = int(_stage_layout.maze_size / 2.0)
	var room_half_size: int = int(_stage_layout.spawn_room_size / 2.0)
	var start: Vector2i = Vector2i(maze_center - room_half_size - 1, maze_center - room_half_size - 1)
	return Rect2i(start, Vector2i(_stage_layout.spawn_room_size + 2, _stage_layout.spawn_room_size + 2))


func _gate_approaches() -> Array[Rect2i]:
	var maze_center: int = int(_stage_layout.maze_size / 2.0)
	var memory_room_half_size: int = int(_stage_layout.memory_room_size / 2.0)
	var spawn_room_half_size: int = int(_stage_layout.spawn_room_size / 2.0)
	var approach_offset: int = maze_center - memory_room_half_size
	var approach_length: int = maze_center - spawn_room_half_size
	var far_approach_start: int = maze_center + spawn_room_half_size + 1
	return [
		Rect2i(approach_offset, 0, _stage_layout.memory_room_size, approach_length),
		Rect2i(approach_offset, far_approach_start, _stage_layout.memory_room_size, approach_length),
		Rect2i(0, approach_offset, approach_length, _stage_layout.memory_room_size),
		Rect2i(far_approach_start, approach_offset, approach_length, _stage_layout.memory_room_size),
	]
