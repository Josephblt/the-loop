class_name DenialEnemy
extends Enemy


const DENIAL_CHASE_SPEED: float = 7.0
const DENIAL_FLANK_SPEED_MULTIPLIER: float = 4.0
const DENIAL_REPATH_INTERVAL: float = 0.2
const DENIAL_WANDER_SPEED: float = 2.0

var _player: Player
var _layout: StageLayout
var _paths: AStar2D = AStar2D.new()
var _cells: Array[Vector2i] = []
var _cell_set: Dictionary = {}
var _blocked_edges: Dictionary = {}
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _target: Vector2i = Vector2i(-1, -1)
var _repath_time: float = 0.0
var _paused: bool = false
var _wandering: bool = false
var _flank_path: PackedVector2Array = PackedVector2Array()
var _was_visible: bool = false
var _flank_player_position: Vector3
var _flank_camera_forward: Vector3


func setup_ai(player: Player, stage_layout: StageLayout, gate: Gate) -> void:
	_player = player
	_layout = stage_layout
	_build_paths()
	var gate_approach: Vector3 = gate.global_position + gate.global_position.direction_to(Vector3.ZERO) * _layout.cell_size
	var start_cell: Vector2i = _nearest_cell(gate_approach)
	global_position = _world_position(start_cell)
	player.paused.connect(_on_player_paused)
	player.resumed.connect(_on_player_resumed)
	appear()


func _physics_process(delta: float) -> void:
	if _player == null or _paused or not emitting:
		return
	_repath_time -= delta
	var in_view: bool = _in_player_view(global_position)
	if in_view != _was_visible:
		_path.clear()
	if _repath_time <= 0.0 or in_view != _was_visible or _wandering == _player_in_maze():
		_repath_time = DENIAL_REPATH_INTERVAL
		_update_path()
	_was_visible = in_view
	_move_enemy(delta)


func _build_paths() -> void:
	for floor_transform: Transform3D in _layout.maze_floor_transforms:
		var cell: Vector2i = _world_to_cell(floor_transform.origin)
		_cells.append(cell)
		_cell_set[cell] = true
		_paths.add_point(_cell_id(cell), Vector2(cell))

	for wall: MazeWall in _layout.maze_walls:
		if wall.wall_size == MazeWall.WallSize.SMALL:
			continue
		var cell: Vector2i = _world_to_cell(wall.transform.origin)
		var normal: Vector3 = -wall.transform.basis.z
		var neighbour: Vector2i = cell + Vector2i(roundi(normal.x), roundi(normal.z))
		_blocked_edges[_edge(cell, neighbour)] = true

	for cell: Vector2i in _cells:
		for direction: Vector2i in [Vector2i.RIGHT, Vector2i.DOWN]:
			var neighbour: Vector2i = cell + direction
			if not _cell_set.has(neighbour) or _blocked_edges.has(_edge(cell, neighbour)):
				continue
			_paths.connect_points(_cell_id(cell), _cell_id(neighbour))


func _update_path() -> void:
	var was_wandering: bool = _wandering
	_wandering = not _player_in_maze()
	if was_wandering != _wandering:
		_target = Vector2i(-1, -1)
		_path.clear()
	var target: Vector2i = _nearest_cell(_player.global_position)
	if _wandering:
		if _path_index >= _path.size():
			target = _cells[randi_range(0, _cells.size() - 1)]
		else:
			target = _target
	elif not _in_player_view(global_position):
		var camera_forward: Vector3 = -_player.camera.global_basis.z
		var player_near: bool = _player.global_position.distance_to(_flank_player_position) < _layout.cell_size
		var view_unchanged: bool = camera_forward.dot(_flank_camera_forward) > 0.866
		if _path_index < _path.size() and player_near and view_unchanged:
			return
		_flank_player_position = _player.global_position
		_flank_camera_forward = camera_forward
		target = _flank_cell()
	if target == _target and _path_index < _path.size():
		return
	_target = target
	var start: Vector2i = _nearest_cell(global_position)
	_path = _flank_path if not _wandering and not _in_player_view(global_position) else _paths.get_point_path(_cell_id(start), _cell_id(target))
	_path_index = 0


func _flank_cell() -> Vector2i:
	var start: Vector2i = _nearest_cell(global_position)
	var minimum_distance: float = Vector2(global_position.x, global_position.z).distance_to(Vector2(_player.global_position.x, _player.global_position.z))
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {start: true}
	var previous: Dictionary = {}
	var fallback: Vector2i = start
	var visible_fallback: Vector2i = start
	var recovered_visible: bool = false
	var best_score: float = -INF
	var camera: Camera3D = _player.camera
	var steps: Dictionary = {start: 0}
	var index: int = 0
	while index < queue.size():
		var cell: Vector2i = queue[index]
		index += 1
		var cell_position: Vector3 = _world_position(cell)
		if cell != start and _in_player_view(cell_position):
			if cell_position.distance_to(_player.global_position) >= minimum_distance:
				fallback = cell
				recovered_visible = true
				break
			if visible_fallback == start:
				visible_fallback = cell
		if steps[cell] >= 4 and steps[cell] <= 8 and cell_position.distance_to(_player.global_position) >= minimum_distance - _layout.cell_size:
			var direction: Vector3 = (cell_position - camera.global_position).normalized()
			var score: float = -camera.global_basis.z.dot(direction) - float(steps[cell]) * 0.05
			if _has_line_of_sight(cell_position):
				score += 2.0
			if score > best_score:
				best_score = score
				fallback = cell
		for neighbour_id: int in _paths.get_point_connections(_cell_id(cell)):
			var neighbour: Vector2i = Vector2i(int(float(neighbour_id) / _layout.maze_size), neighbour_id % _layout.maze_size)
			if visited.has(neighbour) or _segment_closes_distance(cell_position, _world_position(neighbour), minimum_distance):
				continue
			visited[neighbour] = true
			previous[neighbour] = cell
			steps[neighbour] = steps[cell] + 1
			queue.append(neighbour)
	if not recovered_visible and visible_fallback != start:
		fallback = visible_fallback
	_flank_path.clear()
	var step: Vector2i = fallback
	while step != start:
		_flank_path.insert(0, Vector2(step))
		step = previous[step]
	_flank_path.insert(0, Vector2(start))
	return fallback


func _segment_closes_distance(from: Vector3, to: Vector3, minimum_distance: float) -> bool:
	var player_position: Vector2 = Vector2(_player.global_position.x, _player.global_position.z)
	var start: Vector2 = Vector2(from.x, from.z)
	var end: Vector2 = Vector2(to.x, to.z)
	var closest: Vector2 = Geometry2D.get_closest_point_to_segment(player_position, start, end)
	return closest.distance_to(player_position) < minimum_distance - _layout.cell_size


func _player_in_maze() -> bool:
	var player_cell: Vector2i = _world_to_cell(_player.global_position)
	if player_cell.x < 0 or player_cell.y < 0 or player_cell.x >= _layout.maze_size or player_cell.y >= _layout.maze_size:
		return false
	var room_half_size: int = int(_layout.memory_room_size / 2.0)
	for room: Transform3D in _layout.memory_room_transforms:
		var room_center: Vector2i = _world_to_cell(room.origin)
		if abs(player_cell.x - room_center.x) <= room_half_size and abs(player_cell.y - room_center.y) <= room_half_size:
			return false
	var center: int = int(_layout.maze_size / 2.0)
	var acceptance_half_size: int = int(_layout.acceptance_room_size / 2.0)
	return abs(player_cell.x - center) > acceptance_half_size or abs(player_cell.y - center) > acceptance_half_size


func _in_player_view(world_position: Vector3) -> bool:
	var camera: Camera3D = _player.camera
	var view_position: Vector3 = camera.to_local(world_position)
	if view_position.z >= 0.0:
		return false
	var screen_size: Vector2 = camera.get_viewport().get_visible_rect().size
	var half_height: float = -view_position.z * tan(deg_to_rad(camera.fov * 0.5))
	if abs(view_position.y) > half_height or abs(view_position.x) > half_height * screen_size.aspect():
		return false
	return _has_line_of_sight(world_position)


func _has_line_of_sight(world_position: Vector3) -> bool:
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(_player.camera.global_position, world_position, 1)
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func _move_enemy(delta: float) -> void:
	var speed: float = DENIAL_WANDER_SPEED if _wandering else DENIAL_CHASE_SPEED if _in_player_view(global_position) else _player.run_speed * DENIAL_FLANK_SPEED_MULTIPLIER
	var travel: float = speed * delta
	while _path_index < _path.size():
		var cell: Vector2 = _path[_path_index]
		var destination: Vector3 = _world_position(Vector2i(roundi(cell.x), roundi(cell.y)))
		var distance: float = global_position.distance_to(destination)
		global_position = global_position.move_toward(destination, travel)
		if distance > travel:
			return
		travel -= distance
		_path_index += 1
		if travel <= 0.0:
			return


func _nearest_cell(world_position: Vector3) -> Vector2i:
	var nearest: Vector2i = _cells[0]
	var distance: float = world_position.distance_squared_to(_world_position(nearest))
	for cell: Vector2i in _cells:
		var candidate_distance: float = world_position.distance_squared_to(_world_position(cell))
		if candidate_distance < distance:
			nearest = cell
			distance = candidate_distance
	return nearest


func _world_to_cell(world_position: Vector3) -> Vector2i:
	var center: int = int(_layout.maze_size / 2.0)
	return Vector2i(roundi(world_position.x / _layout.cell_size) + center, roundi(world_position.z / _layout.cell_size) + center)


func _world_position(cell: Vector2i) -> Vector3:
	var center: int = int(_layout.maze_size / 2.0)
	return Vector3(float(cell.x - center) * _layout.cell_size, global_position.y, float(cell.y - center) * _layout.cell_size)


func _cell_id(cell: Vector2i) -> int:
	return cell.x * _layout.maze_size + cell.y


func _edge(cell: Vector2i, neighbour: Vector2i) -> Vector4i:
	if neighbour.x < cell.x or (neighbour.x == cell.x and neighbour.y < cell.y):
		return Vector4i(neighbour.x, neighbour.y, cell.x, cell.y)
	return Vector4i(cell.x, cell.y, neighbour.x, neighbour.y)


func _on_player_paused() -> void:
	_paused = true


func _on_player_resumed() -> void:
	_paused = false
