class_name MazeDenial
extends EnemyBehaviour


const SPEED: float = 4.0
const TARGET_UPDATE_INTERVAL: float = 0.2

var _enemy: Enemy
var _player: Player
var _stage_layout: StageLayout
var _target_update_time: float = 0.0
var _was_in_view: bool = false


func setup(enemy: Enemy, player: Player, stage_layout: StageLayout) -> void:
	_enemy = enemy
	_player = player
	_stage_layout = stage_layout


func _physics_process(delta: float) -> void:
	if not _enemy or not _player:
		return

	var in_view: bool = _is_in_player_view()
	_target_update_time -= delta
	if _target_update_time <= 0.0 or in_view != _was_in_view:
		_enemy.navigate_to(_player.global_position if in_view else _orbit_target())
		_target_update_time = TARGET_UPDATE_INTERVAL
	_was_in_view = in_view
	_enemy.move_along_path(delta, SPEED)


func _is_in_player_view() -> bool:
	var forward: Vector2 = _camera_forward()
	var to_enemy: Vector2 = _flat(_enemy.global_position - _player.global_position)
	if to_enemy.is_zero_approx():
		return true
	return absf(forward.angle_to(to_enemy)) <= _half_horizontal_fov()


func _orbit_target() -> Vector3:
	var player_position: Vector2 = _flat(_player.global_position)
	var enemy_position: Vector2 = _flat(_enemy.global_position)
	var distance: float = player_position.distance_to(enemy_position)
	var forward: Vector2 = _camera_forward()
	var half_fov: float = _half_horizontal_fov()
	var left: Vector2 = player_position + forward.rotated(-half_fov) * distance
	var right: Vector2 = player_position + forward.rotated(half_fov) * distance
	var target: Vector2 = left if left.distance_squared_to(enemy_position) < right.distance_squared_to(enemy_position) else right
	var size: float = _stage_layout.cell_size
	return Vector3(roundf(target.x / size) * size, _enemy.global_position.y, roundf(target.y / size) * size)


func _half_horizontal_fov() -> float:
	var camera: Camera3D = _player.camera
	var half_fov: float = deg_to_rad(camera.fov) * 0.5
	if camera.keep_aspect == Camera3D.KEEP_HEIGHT:
		var viewport_size: Vector2 = camera.get_viewport().get_visible_rect().size
		if is_finite(viewport_size.y) and viewport_size.y > 0.0:
			half_fov = atan(tan(half_fov) * viewport_size.x / viewport_size.y)
	return half_fov


func _camera_forward() -> Vector2:
	return _flat(-_player.camera.global_basis.z).normalized()


func _flat(vector: Vector3) -> Vector2:
	return Vector2(vector.x, vector.z)
