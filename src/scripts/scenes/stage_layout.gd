class_name StageLayout
extends RefCounted


const DEFAULT_GRID_SIZE: int = 31
const MINIMUM_GRID_SIZE: int = 17
const CELL_SIZE: float = 5.6
const SPAWN_ROOM_SIZE: int = 7
const MEMORY_ROOM_SIZE: int = 3
const MEMORY_ROOM_COUNT: int = 5

const _MEMORY_ROOM_HALF_SIZE: int = MEMORY_ROOM_SIZE / 2
const _SPAWN_ROOM_HALF_SIZE: int = SPAWN_ROOM_SIZE / 2
const _INNER_GATE_DISTANCE: float = float(_SPAWN_ROOM_HALF_SIZE + 1) * CELL_SIZE

var grid_size: int
var spawn_room_transform: Transform3D = Transform3D.IDENTITY
var depression_room_transform: Transform3D = Transform3D.IDENTITY
var memory_room_positions: Array[Vector2i] = []
var memory_room_transforms: Array[Transform3D] = []
var vertical_gate_transforms: Array[Transform3D] = []
var horizontal_gate_transforms: Array[Transform3D] = []
var maze: Maze

var _grid_center: int


static func create(seed: int, maze_grid_size: int = DEFAULT_GRID_SIZE) -> StageLayout:
	assert(maze_grid_size % 2 == 1, "Maze grid size must be odd")
	assert(maze_grid_size >= MINIMUM_GRID_SIZE, "Maze grid is too small for its rooms")

	var layout: StageLayout = StageLayout.new()
	layout.grid_size = maze_grid_size
	layout._grid_center = maze_grid_size / 2
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = seed

	layout.depression_room_transform = Transform3D(Basis.IDENTITY, Vector3(layout._stage_room_distance(), 0.0, 0.0))
	layout.memory_room_positions = layout._create_memory_room_positions(randomizer)
	layout.memory_room_transforms = layout._create_memory_room_transforms(layout.memory_room_positions, randomizer)
	layout.vertical_gate_transforms = layout._create_vertical_gate_transforms()
	layout.horizontal_gate_transforms = layout._create_horizontal_gate_transforms()
	var excluded_areas: Array[Rect2i] = layout._excluded_areas(layout.memory_room_positions)
	var excluded_cells: Array[Vector2i] = layout._gate_positions()
	layout.maze = Maze.new(maze_grid_size, CELL_SIZE, excluded_areas, excluded_cells)
	return layout


func _create_memory_room_positions(randomizer: RandomNumberGenerator) -> Array[Vector2i]:
	var candidates: Array[Vector2i] = _create_memory_room_candidates()
	ArrayRandomizer.shuffle(candidates, randomizer)

	var selected: Array[Vector2i] = []
	var spacing_points: Array[Vector2i] = _stage_room_positions()
	while selected.size() < MEMORY_ROOM_COUNT:
		var candidate_index: int = _find_farthest_candidate(candidates, selected, spacing_points)
		var selected_position: Vector2i = candidates.pop_at(candidate_index)
		selected.append(selected_position)
		spacing_points.append(selected_position)
	return selected


func _create_memory_room_transforms(positions: Array[Vector2i], randomizer: RandomNumberGenerator) -> Array[Transform3D]:
	var transforms: Array[Transform3D] = []
	for position: Vector2i in positions:
		var rotation: float = float(randomizer.randi_range(0, 3)) * PI / 2.0
		var world_position: Vector3 = Vector3(
			float(position.x - _grid_center) * CELL_SIZE,
			0.0,
			float(position.y - _grid_center) * CELL_SIZE
		)
		transforms.append(Transform3D(Basis(Vector3.UP, rotation), world_position))
	return transforms


func _excluded_areas(memory_room_positions: Array[Vector2i]) -> Array[Rect2i]:
	var spawn_room_start: Vector2i = Vector2i(_grid_center - _SPAWN_ROOM_HALF_SIZE, _grid_center - _SPAWN_ROOM_HALF_SIZE)
	var areas: Array[Rect2i] = [Rect2i(spawn_room_start, Vector2i(SPAWN_ROOM_SIZE, SPAWN_ROOM_SIZE))]
	for position: Vector2i in memory_room_positions:
		areas.append(_memory_room_bounds(position))
	return areas


func _create_memory_room_candidates() -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var minimum_center: int = _MEMORY_ROOM_HALF_SIZE + 1
	var maximum_center: int = grid_size - _MEMORY_ROOM_HALF_SIZE - 1
	var spawn_border: Rect2i = Rect2i(
		Vector2i(_grid_center - _SPAWN_ROOM_HALF_SIZE - 1, _grid_center - _SPAWN_ROOM_HALF_SIZE - 1),
		Vector2i(SPAWN_ROOM_SIZE + 2, SPAWN_ROOM_SIZE + 2)
	)

	for x: int in range(minimum_center, maximum_center):
		for y: int in range(minimum_center, maximum_center):
			var position: Vector2i = Vector2i(x, y)
			if _memory_room_bounds(position).intersects(spawn_border):
				continue
			if _memory_room_contains_gate(position):
				continue
			if _memory_room_intersects_gate_approach(position):
				continue
			candidates.append(position)
	return candidates


func _find_farthest_candidate(candidates: Array[Vector2i], selected: Array[Vector2i], spacing_points: Array[Vector2i]) -> int:
	var farthest_index: int = -1
	var farthest_distance: int = -1

	for index: int in candidates.size():
		var candidate: Vector2i = candidates[index]
		if _overlaps_selected_room(candidate, selected):
			continue

		var distance: int = _minimum_squared_distance(candidate, spacing_points)
		if distance <= farthest_distance:
			continue
		farthest_distance = distance
		farthest_index = index

	assert(farthest_index >= 0, "Unable to place all memory rooms")
	return farthest_index


func _minimum_squared_distance(candidate: Vector2i, selected: Array[Vector2i]) -> int:
	var minimum_distance: int = 2_147_483_647
	for position: Vector2i in selected:
		var offset: Vector2i = candidate - position
		minimum_distance = mini(minimum_distance, offset.length_squared())
	return minimum_distance


func _overlaps_selected_room(candidate: Vector2i, selected: Array[Vector2i]) -> bool:
	var bounds: Rect2i = _memory_room_bounds(candidate)
	for position: Vector2i in selected:
		if bounds.intersects(_memory_room_bounds(position)):
			return true
	return false


func _memory_room_contains_gate(position: Vector2i) -> bool:
	var bounds: Rect2i = _memory_room_bounds(position)
	for gate_position: Vector2i in _gate_positions():
		if bounds.has_point(gate_position):
			return true
	return false


func _memory_room_intersects_gate_approach(position: Vector2i) -> bool:
	var bounds: Rect2i = _memory_room_bounds(position)
	for approach: Rect2i in _gate_approaches():
		if bounds.intersects(approach):
			return true
	return false


func _memory_room_bounds(position: Vector2i) -> Rect2i:
	return Rect2i(
		position - Vector2i(_MEMORY_ROOM_HALF_SIZE, _MEMORY_ROOM_HALF_SIZE),
		Vector2i(MEMORY_ROOM_SIZE, MEMORY_ROOM_SIZE)
	)


func _gate_positions() -> Array[Vector2i]:
	var inner_minimum: int = _grid_center - _SPAWN_ROOM_HALF_SIZE - 1
	var inner_maximum: int = _grid_center + _SPAWN_ROOM_HALF_SIZE + 1
	return [
		Vector2i(_grid_center, 0),
		Vector2i(_grid_center, grid_size - 1),
		Vector2i(0, _grid_center),
		Vector2i(grid_size - 1, _grid_center),
		Vector2i(_grid_center, inner_minimum),
		Vector2i(_grid_center, inner_maximum),
		Vector2i(inner_minimum, _grid_center),
		Vector2i(inner_maximum, _grid_center),
	]


func _gate_approaches() -> Array[Rect2i]:
	var approach_width: int = MEMORY_ROOM_SIZE
	var approach_offset: int = _grid_center - _MEMORY_ROOM_HALF_SIZE
	var approach_length: int = _grid_center - _SPAWN_ROOM_HALF_SIZE
	var far_approach_start: int = _grid_center + _SPAWN_ROOM_HALF_SIZE + 1
	return [
		Rect2i(approach_offset, 0, approach_width, approach_length),
		Rect2i(approach_offset, far_approach_start, approach_width, approach_length),
		Rect2i(0, approach_offset, approach_length, approach_width),
		Rect2i(far_approach_start, approach_offset, approach_length, approach_width),
	]


func _stage_room_positions() -> Array[Vector2i]:
	var stage_room_offset: int = (grid_size + SPAWN_ROOM_SIZE) / 2
	return [
		Vector2i(_grid_center, _grid_center - stage_room_offset),
		Vector2i(_grid_center, _grid_center + stage_room_offset),
		Vector2i(_grid_center - stage_room_offset, _grid_center),
		Vector2i(_grid_center + stage_room_offset, _grid_center),
	]


func _create_vertical_gate_transforms() -> Array[Transform3D]:
	var outer_gate_distance: float = float(_grid_center + 1) * CELL_SIZE
	return [
		_transform(Vector3(0.0, 0.0, -_INNER_GATE_DISTANCE), PI),
		_transform(Vector3(0.0, 0.0, _INNER_GATE_DISTANCE), 0.0),
		_transform(Vector3(0.0, 0.0, -outer_gate_distance), PI),
		_transform(Vector3(0.0, 0.0, outer_gate_distance), 0.0),
	]


func _create_horizontal_gate_transforms() -> Array[Transform3D]:
	var outer_gate_distance: float = float(_grid_center + 1) * CELL_SIZE
	return [
		_transform(Vector3(-_INNER_GATE_DISTANCE, 0.0, 0.0), PI),
		_transform(Vector3(_INNER_GATE_DISTANCE, 0.0, 0.0), 0.0),
		_transform(Vector3(-outer_gate_distance, 0.0, 0.0), PI),
		_transform(Vector3(outer_gate_distance, 0.0, 0.0), 0.0),
	]


func _stage_room_distance() -> float:
	return (float(grid_size + SPAWN_ROOM_SIZE) / 2.0) * CELL_SIZE


func _transform(position: Vector3, rotation: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, rotation), position)
