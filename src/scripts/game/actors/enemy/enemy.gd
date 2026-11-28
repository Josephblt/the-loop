class_name Enemy
extends GPUParticles3D


@export var ai_behaviour: EnemyBehaviour

var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _debug_path_line: MeshInstance3D


func set_path(path: PackedVector2Array, color: Color) -> void:
	_path = path
	_path_index = 0
	_draw_debug_path(color)


func clear_path() -> void:
	_path = PackedVector2Array()
	_path_index = 0
	if is_instance_valid(_debug_path_line):
		_debug_path_line.mesh = null


func has_path() -> bool:
	return _path_index < _path.size()


func move_along_path(delta: float, speed: float) -> void:
	if _path_index >= _path.size():
		return

	var waypoint: Vector2 = _path[_path_index]
	var destination: Vector3 = Vector3(waypoint.x, position.y, waypoint.y)
	position = position.move_toward(destination, speed * delta)

	if position.distance_squared_to(destination) < 0.0001:
		_path_index += 1


func _draw_debug_path(color: Color) -> void:
	if not is_instance_valid(_debug_path_line):
		_debug_path_line = MeshInstance3D.new()
		_debug_path_line.name = "EnemyDebugPath"
		get_parent().add_child(_debug_path_line)

	if _path.size() < 2:
		_debug_path_line.mesh = null
		return

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.no_depth_test = true

	var mesh: ImmediateMesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)
	for point: Vector2 in _path:
		mesh.surface_add_vertex(Vector3(point.x, position.y + 0.2, point.y))
	mesh.surface_end()
	_debug_path_line.mesh = mesh


func appear() -> void:
	print("Enemy appearing:" + str(emitting))
	emitting = true
	print("Enemy appeared:" + str(emitting))


func disappear() -> void:
	print("Enemy disappearing:" + str(emitting))
	emitting = false
	clear_path()
	print("Enemy disappeared:" + str(emitting))
