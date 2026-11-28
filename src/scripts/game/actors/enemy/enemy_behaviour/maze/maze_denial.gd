class_name MazeDenial
extends EnemyBehaviour


const ORBIT_SPEED_MULTIPLIER: float = 5.0

var _graph: MazePathGraph
var _entry_distance_captured: bool = false
var _was_in_view: bool = false
var _orbit_planned: bool = false
var _orbit_has_goal: bool = false
var _orbit_radius: float = 0.0
var _orbit_goal: Vector2 = Vector2.ZERO
var _planned_forward: Vector2 = Vector2.ZERO
var _planned_player_position: Vector2 = Vector2.ZERO
var _last_player_cell: Vector2i

var _fov_line_distance: float = 0.0
var _fov_line: MeshInstance3D
var _fov_mesh: ImmediateMesh = ImmediateMesh.new()
var _fov_material: StandardMaterial3D = StandardMaterial3D.new()


func setup_maze(enemy: Enemy, player: Player, graph: MazePathGraph) -> void:
	super.setup(enemy, player)
	_graph = graph

	_fov_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_fov_material.albedo_color = Color(0.0, 0.8, 1.0)
	_fov_material.no_depth_test = true

	_fov_line = MeshInstance3D.new()
	_fov_line.name = "DenialFovDebug"
	_fov_line.mesh = _fov_mesh
	_enemy.get_parent().add_child(_fov_line)


func _physics_process(delta: float) -> void:
	if not _entry_distance_captured:
		_orbit_radius = _flat(_enemy.global_position).distance_to(_flat(_player.global_position))
		_entry_distance_captured = true

	_draw_fov_lines()

	if _is_in_player_view():
		_attack(delta)
		_set_state_from_path("Attack")
		return

	_was_in_view = false
	if _orbit_route_stale():
		_plan_orbit()
	if _orbit_has_goal:
		_enemy.move_along_path(delta, _player.movement_speed * ORBIT_SPEED_MULTIPLIER)
	_set_state_from_path("Orbit")


func _set_state_from_path(active_state: String) -> void:
	set_state(active_state if _enemy.has_path() else "Wander")


func _attack(delta: float) -> void:
	_orbit_planned = false
	_orbit_radius = _flat(_enemy.global_position).distance_to(_flat(_player.global_position))

	var player_cell: Vector2i = _player_cell()
	if not _was_in_view or player_cell != _last_player_cell:
		_enemy.set_path(_graph.get_path(_enemy.position, _player.global_position), Color.RED)
		_last_player_cell = player_cell

	_was_in_view = true
	_enemy.move_along_path(delta, _player.movement_speed)


func _orbit_route_stale() -> bool:
	if not _orbit_planned:
		return true

	var player_position: Vector2 = _flat(_player.global_position)
	var movement_limit: float = StageLayout.CELL_SIZE * 0.5
	if player_position.distance_squared_to(_planned_player_position) > movement_limit * movement_limit:
		return true
	if _orbit_has_goal:
		return not _is_point_in_player_view(_orbit_goal)
	return absf(_planned_forward.angle_to(_camera_forward())) > _half_horizontal_fov() * 0.5


func _plan_orbit() -> void:
	var player_position: Vector2 = _flat(_player.global_position)
	var forward: Vector2 = _camera_forward()
	var half_fov: float = _half_horizontal_fov()
	var effective_radius: float = _orbit_radius
	var path: PackedVector2Array = _orbit_path(player_position, forward, half_fov, effective_radius)

	if path.is_empty() and _orbit_radius > 0.0:
		var zero_radius_path: PackedVector2Array = _orbit_path(player_position, forward, half_fov, 0.0)
		if not zero_radius_path.is_empty():
			var low: int = 1
			var high: int = ceili(_orbit_radius / StageLayout.CELL_SIZE)

			while low < high:
				var middle: int = int((low + high) / 2.0)
				var candidate_radius: float = maxf(_orbit_radius - float(middle) * StageLayout.CELL_SIZE, 0.0)
				var candidate_path: PackedVector2Array = _orbit_path(player_position, forward, half_fov, candidate_radius)
				if candidate_path.is_empty():
					low = middle + 1
				else:
					high = middle

			effective_radius = maxf(_orbit_radius - float(low) * StageLayout.CELL_SIZE, 0.0)
			path = _orbit_path(player_position, forward, half_fov, effective_radius)

	_orbit_planned = true
	_planned_player_position = player_position
	_planned_forward = forward
	_orbit_has_goal = not path.is_empty()
	_enemy.set_path(path, Color.GREEN)

	if not _orbit_has_goal:
		print("Orbit: no visible reachable cell even at radius 0")
		return

	_orbit_goal = path[path.size() - 1]
	_fov_line_distance = player_position.distance_to(_orbit_goal) + StageLayout.CELL_SIZE
	print("Orbit route points: ", path.size(), " preferred radius: ", _orbit_radius, " used radius: ", effective_radius)


func _orbit_path(player_position: Vector2, forward: Vector2, half_fov: float, radius: float) -> PackedVector2Array:
	return _graph.get_path_to_view(_enemy.position, player_position, forward, half_fov, radius)


func _draw_fov_lines() -> void:
	var player_position: Vector2 = _flat(_player.global_position)
	var forward: Vector2 = _camera_forward()
	var distance: float = maxf(player_position.distance_to(_flat(_enemy.global_position)), _fov_line_distance)
	distance = maxf(distance, StageLayout.CELL_SIZE)
	var half_fov: float = _half_horizontal_fov()
	var left: Vector2 = player_position + forward.rotated(-half_fov) * distance
	var right: Vector2 = player_position + forward.rotated(half_fov) * distance
	var height: float = _enemy.global_position.y + 0.2
	var room: Node3D = _fov_line.get_parent() as Node3D
	var start: Vector3 = room.to_local(Vector3(player_position.x, height, player_position.y))
	var left_end: Vector3 = room.to_local(Vector3(left.x, height, left.y))
	var right_end: Vector3 = room.to_local(Vector3(right.x, height, right.y))

	_fov_mesh.clear_surfaces()
	_fov_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _fov_material)
	_fov_mesh.surface_add_vertex(start)
	_fov_mesh.surface_add_vertex(left_end)
	_fov_mesh.surface_add_vertex(start)
	_fov_mesh.surface_add_vertex(right_end)
	_fov_mesh.surface_add_vertex(left_end)
	_fov_mesh.surface_add_vertex(right_end)
	_fov_mesh.surface_end()


func _is_in_player_view() -> bool:
	return _is_point_in_player_view(_flat(_enemy.global_position))


func _is_point_in_player_view(point: Vector2) -> bool:
	var direction: Vector2 = point - _flat(_player.global_position)
	if direction.is_zero_approx():
		return true
	return absf(_camera_forward().angle_to(direction)) <= _half_horizontal_fov()


func _player_cell() -> Vector2i:
	return Vector2i(
		roundi(_player.global_position.x / StageLayout.CELL_SIZE),
		roundi(_player.global_position.z / StageLayout.CELL_SIZE)
	)


func _half_horizontal_fov() -> float:
	var camera: Camera3D = _player.camera
	var horizontal_fov: float = deg_to_rad(camera.fov)
	if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
		var viewport_size: Vector2 = camera.get_viewport().get_visible_rect().size
		if is_finite(viewport_size.y) and viewport_size.y > 0.0:
			horizontal_fov = 2.0 * atan(tan(horizontal_fov * 0.5) * viewport_size.x / viewport_size.y)
	return horizontal_fov / 3.5


func _camera_forward() -> Vector2:
	return _flat(-_player.camera.global_basis.z).normalized()


func _flat(vector: Vector3) -> Vector2:
	return Vector2(vector.x, vector.z)
