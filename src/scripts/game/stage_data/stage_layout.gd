class_name StageLayout
extends Resource

@export var cell_size: float = 5.6
@export var spawn_room_size: int = 7

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


func _spawn_gate_transform(direction: Vector3, rotation: float) -> Transform3D:
	var room_half_size: int = int(spawn_room_size / 2.0)
	var gate_distance: float = float(room_half_size + 1) * cell_size
	return Transform3D(Basis(Vector3.UP, rotation), direction * gate_distance)
