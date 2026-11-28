class_name MazePathGraph
extends RefCounted


class FilteredAStar extends AStar2D:
	var avoidance_center: Vector2
	var avoidance_radius: float = 0.0

	func _filter_neighbor(from_id: int, neighbor_id: int) -> bool:
		return blocks_edge(from_id, neighbor_id)

	func blocks_edge(from_id: int, neighbor_id: int) -> bool:
		if avoidance_radius <= 0.0:
			return false

		var start: Vector2 = get_point_position(from_id)
		var end: Vector2 = get_point_position(neighbor_id)
		var segment: Vector2 = end - start
		var radius_squared: float = avoidance_radius * avoidance_radius
		var start_distance_squared: float = start.distance_squared_to(avoidance_center)

		if start_distance_squared < radius_squared:
			return (start - avoidance_center).dot(segment) < 0.0

		var fraction: float = clampf((avoidance_center - start).dot(segment) / segment.length_squared(), 0.0, 1.0)
		var closest: Vector2 = start + segment * fraction
		return closest.distance_squared_to(avoidance_center) < radius_squared


var _astar: FilteredAStar = FilteredAStar.new()
var _cell_ids: Dictionary = {}
var _blocked_edges: Dictionary = {}
var _maze_size: int


func _init(layout: StageLayout) -> void:
	_maze_size = layout.maze_size
	_astar.neighbor_filter_enabled = true

	for floor_transform: Transform3D in layout.maze_floor_transforms:
		_add_cell(_world_to_cell(floor_transform.origin))

	_add_gate_cells(layout)

	for wall: MazeWall in layout.maze_walls:
		if wall.wall_size != MazeWall.WallSize.SMALL:
			_blocked_edges[_edge_key(wall.cell, wall.neighbour)] = true

	for cell: Vector2i in _cell_ids.keys():
		for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
			var neighbour: Vector2i = cell + direction
			if not _cell_ids.has(neighbour):
				continue
			if _blocked_edges.has(_edge_key(cell, neighbour)):
				continue
			_astar.connect_points(int(_cell_ids[cell]), int(_cell_ids[neighbour]))


func get_point_count() -> int:
	return _astar.get_point_count()


func get_path(start: Vector3, target: Vector3) -> PackedVector2Array:
	var start_cell: Vector2i = _world_to_cell(start)
	var target_cell: Vector2i = _world_to_cell(target)
	if not _cell_ids.has(start_cell) or not _cell_ids.has(target_cell):
		return PackedVector2Array()
	return _astar.get_point_path(int(_cell_ids[start_cell]), int(_cell_ids[target_cell]))


func get_path_avoiding(start: Vector3, target: Vector3, center: Vector2, radius: float) -> PackedVector2Array:
	_astar.avoidance_center = center
	_astar.avoidance_radius = maxf(radius, 0.0)
	var path: PackedVector2Array = get_path(start, target)
	_astar.avoidance_radius = 0.0
	return path


func get_path_to_view(start: Vector3, player_position: Vector2, forward: Vector2, half_fov: float, radius: float) -> PackedVector2Array:
	var start_cell: Vector2i = _world_to_cell(start)
	if not _cell_ids.has(start_cell):
		return PackedVector2Array()

	_astar.avoidance_center = player_position
	_astar.avoidance_radius = maxf(radius, 0.0)

	var start_id: int = int(_cell_ids[start_cell])
	var queue: Array[int] = [start_id]
	var previous: Dictionary = {}
	previous[start_id] = -1
	var head: int = 0

	while head < queue.size():
		var current_id: int = queue[head]
		head += 1

		var point: Vector2 = _astar.get_point_position(current_id)
		if _is_visible_goal(point, player_position, forward, half_fov, radius):
			var path: PackedVector2Array = _path_from_previous(current_id, previous)
			_astar.avoidance_radius = 0.0
			return _include_start_if_needed(path, start)

		for neighbor_id: int in _astar.get_point_connections(current_id):
			if previous.has(neighbor_id) or _astar.blocks_edge(current_id, neighbor_id):
				continue
			previous[neighbor_id] = current_id
			queue.append(neighbor_id)

	_astar.avoidance_radius = 0.0
	return PackedVector2Array()


func _is_visible_goal(point: Vector2, player_position: Vector2, forward: Vector2, half_fov: float, radius: float) -> bool:
	var direction: Vector2 = point - player_position
	if direction.length_squared() < radius * radius:
		return false
	if direction.is_zero_approx():
		return true
	return absf(forward.angle_to(direction)) <= half_fov


func _path_from_previous(goal_id: int, previous: Dictionary) -> PackedVector2Array:
	var reversed_points: Array[Vector2] = []
	var current_id: int = goal_id
	while current_id >= 0:
		reversed_points.append(_astar.get_point_position(current_id))
		current_id = int(previous[current_id])

	var path: PackedVector2Array = PackedVector2Array()
	for index: int in range(reversed_points.size() - 1, -1, -1):
		path.append(reversed_points[index])
	return path


func _include_start_if_needed(path: PackedVector2Array, start: Vector3) -> PackedVector2Array:
	if path.size() != 1:
		return path

	var start_position: Vector2 = Vector2(start.x, start.z)
	if start_position.distance_squared_to(path[0]) < 0.0001:
		return path

	var full_path: PackedVector2Array = PackedVector2Array()
	full_path.append(start_position)
	full_path.append(path[0])
	return full_path


func _add_gate_cells(layout: StageLayout) -> void:
	var center: int = int(layout.maze_size / 2.0)
	var last: int = layout.maze_size - 1
	var inner: int = int(layout.acceptance_room_size / 2.0) + layout.spawn_room_entrance_offset + 1
	var gate_cells: Array[Vector2i] = [
		Vector2i(center, 0),
		Vector2i(center, last),
		Vector2i(0, center),
		Vector2i(last, center),
		Vector2i(center, center - inner),
		Vector2i(center, center + inner),
		Vector2i(center - inner, center),
		Vector2i(center + inner, center),
	]
	for cell: Vector2i in gate_cells:
		_add_cell(cell)


func _add_cell(cell: Vector2i) -> void:
	if _cell_ids.has(cell):
		return
	var id: int = cell.x * _maze_size + cell.y
	var center: int = int(_maze_size / 2.0)
	var position: Vector2 = Vector2(float(cell.x - center), float(cell.y - center)) * StageLayout.CELL_SIZE
	_cell_ids[cell] = id
	_astar.add_point(id, position)


func _world_to_cell(position: Vector3) -> Vector2i:
	var center: int = int(_maze_size / 2.0)
	return Vector2i(roundi(position.x / StageLayout.CELL_SIZE) + center, roundi(position.z / StageLayout.CELL_SIZE) + center)


func _edge_key(first: Vector2i, second: Vector2i) -> Vector2i:
	var first_id: int = first.x * _maze_size + first.y
	var second_id: int = second.x * _maze_size + second.y
	return Vector2i(mini(first_id, second_id), maxi(first_id, second_id))