class_name StageLayout
extends RefCounted


const GRID_SIZE: int = 31
const CELL_SIZE: float = 5.6
const SPAWN_ROOM_SIZE: int = 7
const MEMORY_ROOM_SIZE: int = 3
const MEMORY_ROOM_COUNT: int = 5

const _GRID_CENTER: int = GRID_SIZE / 2
const _MEMORY_ROOM_HALF_SIZE: int = MEMORY_ROOM_SIZE / 2
const _SPAWN_ROOM_HALF_SIZE: int = SPAWN_ROOM_SIZE / 2
const _INNER_GATE_DISTANCE: float = float(_SPAWN_ROOM_HALF_SIZE + 1) * CELL_SIZE
const _OUTER_GATE_DISTANCE: float = float(_GRID_CENTER + 1) * CELL_SIZE
const _STAGE_ROOM_DISTANCE: float = (float(GRID_SIZE + SPAWN_ROOM_SIZE) / 2.0) * CELL_SIZE

var spawn_room_transform: Transform3D = Transform3D.IDENTITY
var depression_room_transform: Transform3D = Transform3D.IDENTITY
var memory_room_transforms: Array[Transform3D] = []
var vertical_gate_transforms: Array[Transform3D] = []
var horizontal_gate_transforms: Array[Transform3D] = []


static func create(seed: int) -> StageLayout:
	var layout: StageLayout = StageLayout.new()
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = seed

	layout.depression_room_transform = Transform3D(Basis.IDENTITY, Vector3(_STAGE_ROOM_DISTANCE, 0.0, 0.0))
	layout.memory_room_transforms = _create_memory_room_transforms(randomizer)
	layout.vertical_gate_transforms = _create_vertical_gate_transforms()
	layout.horizontal_gate_transforms = _create_horizontal_gate_transforms()
	return layout


static func _create_memory_room_transforms(randomizer: RandomNumberGenerator) -> Array[Transform3D]:
	var candidates: Array[Vector2i] = _create_memory_room_candidates()
	ArrayRandomizer.shuffle(candidates, randomizer)

	var selected: Array[Vector2i] = [candidates.pop_back()]
	while selected.size() < MEMORY_ROOM_COUNT:
		var candidate_index: int = _find_farthest_candidate(candidates, selected)
		selected.append(candidates.pop_at(candidate_index))

	var transforms: Array[Transform3D] = []
	for position: Vector2i in selected:
		var rotation: float = float(randomizer.randi_range(0, 3)) * PI / 2.0
		var world_position: Vector3 = Vector3(
			float(position.x - _GRID_CENTER) * CELL_SIZE,
			0.0,
			float(position.y - _GRID_CENTER) * CELL_SIZE
		)
		transforms.append(Transform3D(Basis(Vector3.UP, rotation), world_position))
	return transforms


static func _create_memory_room_candidates() -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var minimum_center: int = _MEMORY_ROOM_HALF_SIZE + 1
	var maximum_center: int = GRID_SIZE - _MEMORY_ROOM_HALF_SIZE - 1
	var spawn_border: Rect2i = Rect2i(
		Vector2i(_GRID_CENTER - _SPAWN_ROOM_HALF_SIZE - 1, _GRID_CENTER - _SPAWN_ROOM_HALF_SIZE - 1),
		Vector2i(SPAWN_ROOM_SIZE + 2, SPAWN_ROOM_SIZE + 2)
	)

	for x: int in range(minimum_center, maximum_center):
		for y: int in range(minimum_center, maximum_center):
			var position: Vector2i = Vector2i(x, y)
			if _memory_room_bounds(position).intersects(spawn_border):
				continue
			if _memory_room_contains_gate(position):
				continue
			candidates.append(position)
	return candidates


static func _find_farthest_candidate(candidates: Array[Vector2i], selected: Array[Vector2i]) -> int:
	var farthest_index: int = -1
	var farthest_distance: int = -1

	for index: int in candidates.size():
		var candidate: Vector2i = candidates[index]
		if _overlaps_selected_room(candidate, selected):
			continue

		var distance: int = _minimum_squared_distance(candidate, selected)
		if distance <= farthest_distance:
			continue
		farthest_distance = distance
		farthest_index = index

	assert(farthest_index >= 0, "Unable to place all memory rooms")
	return farthest_index


static func _minimum_squared_distance(candidate: Vector2i, selected: Array[Vector2i]) -> int:
	var minimum_distance: int = 2_147_483_647
	for position: Vector2i in selected:
		var offset: Vector2i = candidate - position
		minimum_distance = mini(minimum_distance, offset.length_squared())
	return minimum_distance


static func _overlaps_selected_room(candidate: Vector2i, selected: Array[Vector2i]) -> bool:
	var bounds: Rect2i = _memory_room_bounds(candidate)
	for position: Vector2i in selected:
		if bounds.intersects(_memory_room_bounds(position)):
			return true
	return false


static func _memory_room_contains_gate(position: Vector2i) -> bool:
	var bounds: Rect2i = _memory_room_bounds(position)
	for gate_position: Vector2i in _gate_positions():
		if bounds.has_point(gate_position):
			return true
	return false


static func _memory_room_bounds(position: Vector2i) -> Rect2i:
	return Rect2i(
		position - Vector2i(_MEMORY_ROOM_HALF_SIZE, _MEMORY_ROOM_HALF_SIZE),
		Vector2i(MEMORY_ROOM_SIZE, MEMORY_ROOM_SIZE)
	)


static func _gate_positions() -> Array[Vector2i]:
	var inner_minimum: int = _GRID_CENTER - _SPAWN_ROOM_HALF_SIZE - 1
	var inner_maximum: int = _GRID_CENTER + _SPAWN_ROOM_HALF_SIZE + 1
	return [
		Vector2i(_GRID_CENTER, 0),
		Vector2i(_GRID_CENTER, GRID_SIZE - 1),
		Vector2i(0, _GRID_CENTER),
		Vector2i(GRID_SIZE - 1, _GRID_CENTER),
		Vector2i(_GRID_CENTER, inner_minimum),
		Vector2i(_GRID_CENTER, inner_maximum),
		Vector2i(inner_minimum, _GRID_CENTER),
		Vector2i(inner_maximum, _GRID_CENTER),
	]


static func _create_vertical_gate_transforms() -> Array[Transform3D]:
	return [
		_transform(Vector3(0.0, 0.0, -_INNER_GATE_DISTANCE), PI),
		_transform(Vector3(0.0, 0.0, _INNER_GATE_DISTANCE), 0.0),
		_transform(Vector3(0.0, 0.0, -_OUTER_GATE_DISTANCE), PI),
		_transform(Vector3(0.0, 0.0, _OUTER_GATE_DISTANCE), 0.0),
	]


static func _create_horizontal_gate_transforms() -> Array[Transform3D]:
	return [
		_transform(Vector3(-_INNER_GATE_DISTANCE, 0.0, 0.0), PI),
		_transform(Vector3(_INNER_GATE_DISTANCE, 0.0, 0.0), 0.0),
		_transform(Vector3(-_OUTER_GATE_DISTANCE, 0.0, 0.0), PI),
		_transform(Vector3(_OUTER_GATE_DISTANCE, 0.0, 0.0), 0.0),
	]


static func _transform(position: Vector3, rotation: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, rotation), position)
