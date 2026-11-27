class_name DenialEnemy
extends Enemy


const DENIAL_CHASE_SPEED: float = 7.0
const DENIAL_FLANK_SPEED_MULTIPLIER: float = 4.0
const DENIAL_REPATH_INTERVAL: float = 0.2

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
	if _repath_time <= 0.0:
		_repath_time = DENIAL_REPATH_INTERVAL
		_update_path()
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
	var player_cell: Vector2i = _nearest_cell(_player.global_position)
	var target: Vector2i = player_cell
	if not _in_player_view(global_position):
		target = _flank_cell(player_cell)
	if target == _target and _path_index < _path.size():
		return
	_target = target
	var start: Vector2i = _nearest_cell(global_position)
	_path = _paths.get_point_path(_cell_id(start), _cell_id(target))
	_path_index = 0


func _flank_cell(player_cell: Vector2i) -> Vector2i:
	var best: Vector2i = player_cell
	var best_score: float = INF
	var player_position: Vector3 = _player.global_position
	var camera: Camera3D = _player.camera
	for cell: Vector2i in _cells:
		var candidate_position: Vector3 = _world_position(cell)
		var distance: float = candidate_position.distance_to(player_position)
		if distance > _layout.cell_size * 3.0 or not _in_player_view(candidate_position):
			continue
		var side: float = abs((candidate_position - player_position).normalized().dot(camera.global_basis.x))
		var score: float = candidate_position.distance_to(global_position) + distance - side * _layout.cell_size
		if score < best_score:
			best_score = score
			best = cell
	return best


func _in_player_view(world_position: Vector3) -> bool:
	var camera: Camera3D = _player.camera
	var view_position: Vector3 = camera.to_local(world_position)
	if view_position.z >= 0.0:
		return false
	var screen_size: Vector2 = camera.get_viewport().get_visible_rect().size
	var half_height: float = -view_position.z * tan(deg_to_rad(camera.fov * 0.5))
	if abs(view_position.y) > half_height or abs(view_position.x) > half_height * screen_size.aspect():
		return false
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(camera.global_position, world_position, 1)
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func _move_enemy(delta: float) -> void:
	var speed: float = DENIAL_CHASE_SPEED if _in_player_view(global_position) else _player.run_speed * DENIAL_FLANK_SPEED_MULTIPLIER
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
