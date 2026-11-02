class_name StageLayout
extends Resource

@export var cell_size: float = 5.6
@export var spawn_room_size: int = 7
@export var maze_size: int = 21
@export var grief_room_size: int = 7
@export var grief_room_entrance_offset: int = 2
@export var memory_room_size: int = 3

@export var stories: Array[Story] = []

var spawn_north_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.FORWARD, PI)

var spawn_south_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.BACK, 0.0)

var spawn_west_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.LEFT, PI)

var spawn_east_gate_transform: Transform3D:
	get:
		return _spawn_gate_transform(Vector3.RIGHT, 0.0)

var anger_room_gate_transform: Transform3D:
	get:
		return _grief_room_gate_transform(Vector3.BACK, 0.0)

var denial_room_gate_transform: Transform3D:
	get:
		return _grief_room_gate_transform(Vector3.FORWARD, PI)

var bargaining_room_gate_transform: Transform3D:
	get:
		return _grief_room_gate_transform(Vector3.LEFT, PI)

var depression_room_gate_transform: Transform3D:
	get:
		return _grief_room_gate_transform(Vector3.RIGHT, 0.0)

var anger_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.BACK)

var denial_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.FORWARD)

var bargaining_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.LEFT)

var depression_room_transform: Transform3D:
	get:
		return _grief_room_transform(Vector3.RIGHT)


func memory_room_transforms(random_seed: int, room_count: int) -> Array[Transform3D]:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = random_seed
	var positions: Array[Vector2i] = _memory_room_positions(randomizer, room_count)
	var transforms: Array[Transform3D] = []
	var maze_center: int = int(maze_size / 2.0)
	for position: Vector2i in positions:
		var rotation: float = float(randomizer.randi_range(0, 3)) * PI / 2.0
		var offset: Vector2i = position - Vector2i(maze_center, maze_center)
		var world_position: Vector3 = Vector3(float(offset.x) * cell_size, 0.0, float(offset.y) * cell_size)
		transforms.append(Transform3D(Basis(Vector3.UP, rotation), world_position))
	return transforms


func _spawn_gate_transform(direction: Vector3, rotation: float) -> Transform3D:
	var room_half_size: int = int(spawn_room_size / 2.0)
	var gate_distance: float = float(room_half_size + 1) * cell_size
	return Transform3D(Basis(Vector3.UP, rotation), direction * gate_distance)


func _grief_room_gate_transform(direction: Vector3, rotation: float) -> Transform3D:
	var maze_half_size: int = int(maze_size / 2.0)
	var gate_distance: float = float(maze_half_size + 1) * cell_size
	return Transform3D(Basis(Vector3.UP, rotation), direction * gate_distance)


func _grief_room_transform(direction: Vector3) -> Transform3D:
	var maze_half_size: int = int(maze_size / 2.0)
	var room_half_size: int = int(grief_room_size / 2.0)
	var room_distance: float = float(maze_half_size + 1 + grief_room_entrance_offset + room_half_size) * cell_size
	return Transform3D(Basis.IDENTITY, direction * room_distance)


func _memory_room_positions(randomizer: RandomNumberGenerator, room_count: int) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = _memory_room_candidates()
	ArrayRandomizer.shuffle(candidates, randomizer)
	var selected: Array[Vector2i] = []
	var spacing_points: Array[Vector2i] = _grief_room_positions()
	while selected.size() < room_count:
		var candidate_index: int = _farthest_memory_room_candidate(candidates, selected, spacing_points)
		var position: Vector2i = candidates.pop_at(candidate_index)
		selected.append(position)
		spacing_points.append(position)
	return selected


func _memory_room_candidates() -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var room_half_size: int = int(memory_room_size / 2.0)
	var minimum_center: int = room_half_size + 1
	var maximum_center: int = maze_size - room_half_size - 1
	for x: int in range(minimum_center, maximum_center):
		for y: int in range(minimum_center, maximum_center):
			var position: Vector2i = Vector2i(x, y)
			if _memory_room_is_available(position):
				candidates.append(position)
	return candidates


func _memory_room_is_available(position: Vector2i) -> bool:
	var bounds: Rect2i = _memory_room_bounds(position)
	if bounds.intersects(_spawn_room_border()):
		return false
	for approach: Rect2i in _gate_approaches():
		if bounds.intersects(approach):
			return false
	return true


func _farthest_memory_room_candidate(candidates: Array[Vector2i], selected: Array[Vector2i], spacing_points: Array[Vector2i]) -> int:
	var farthest_index: int = -1
	var farthest_distance: int = -1
	for index: int in candidates.size():
		var candidate: Vector2i = candidates[index]
		if _overlaps_memory_room(candidate, selected):
			continue
		var distance: int = _minimum_squared_distance(candidate, spacing_points)
		if distance <= farthest_distance:
			continue
		farthest_distance = distance
		farthest_index = index
	assert(farthest_index >= 0, "Unable to place all memory rooms")
	return farthest_index


func _overlaps_memory_room(candidate: Vector2i, selected: Array[Vector2i]) -> bool:
	var bounds: Rect2i = _memory_room_bounds(candidate)
	for position: Vector2i in selected:
		if bounds.intersects(_memory_room_bounds(position)):
			return true
	return false


func _minimum_squared_distance(candidate: Vector2i, positions: Array[Vector2i]) -> int:
	var minimum_distance: int = 2_147_483_647
	for position: Vector2i in positions:
		minimum_distance = mini(minimum_distance, (candidate - position).length_squared())
	return minimum_distance


func _memory_room_bounds(position: Vector2i) -> Rect2i:
	var room_half_size: int = int(memory_room_size / 2.0)
	var offset: Vector2i = Vector2i(room_half_size, room_half_size)
	return Rect2i(position - offset, Vector2i(memory_room_size, memory_room_size))


func _spawn_room_border() -> Rect2i:
	var maze_center: int = int(maze_size / 2.0)
	var room_half_size: int = int(spawn_room_size / 2.0)
	var start: Vector2i = Vector2i(maze_center - room_half_size - 1, maze_center - room_half_size - 1)
	return Rect2i(start, Vector2i(spawn_room_size + 2, spawn_room_size + 2))


func _gate_approaches() -> Array[Rect2i]:
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


func _grief_room_positions() -> Array[Vector2i]:
	var maze_center: int = int(maze_size / 2.0)
	var room_half_size: int = int(grief_room_size / 2.0)
	var room_offset: int = maze_center + 1 + grief_room_entrance_offset + room_half_size
	return [
		Vector2i(maze_center, maze_center - room_offset),
		Vector2i(maze_center, maze_center + room_offset),
		Vector2i(maze_center - room_offset, maze_center),
		Vector2i(maze_center + room_offset, maze_center),
	]
