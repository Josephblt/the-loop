class_name FireLight
extends OmniLight3D


@export_range(0.0, 1.0, 0.01) var energy_variation: float = 0.1
@export_range(0.0, 1.0, 0.01) var range_variation: float = 0.1
@export_range(0.1, 10.0, 0.1) var flicker_speed: float = 5.0
@export_range(0.0, 1.0, 0.01) var position_variation: float = 0.1
@export_range(0.1, 10.0, 0.1) var movement_speed: float = 1.0

var _base_energy: float
var _base_range: float
var _base_position: Vector3
var _elapsed_time: float
var _movement_time: float
var _noise: FastNoiseLite = FastNoiseLite.new()


func _ready() -> void:
	_base_energy = light_energy
	_base_range = omni_range
	_base_position = position
	_noise.frequency = 1.0


func _process(delta: float) -> void:
	if not visible:
		return

	_elapsed_time += delta * flicker_speed
	_movement_time += delta * movement_speed

	var flame_body: float = _noise.get_noise_1d(_elapsed_time)
	var flame_flutter: float = _noise.get_noise_1d(_elapsed_time * 2.7 + 100.0)
	var flicker: float = clampf(flame_body * 0.7 + flame_flutter * 0.3, -1.0, 1.0)

	var x: float = _noise.get_noise_1d(_movement_time + 200.0)
	var y: float = _noise.get_noise_1d(_movement_time + 300.0)
	var z: float = _noise.get_noise_1d(_movement_time + 400.0)

	light_energy = _base_energy * (1.0 + flicker * energy_variation)
	omni_range = _base_range * (1.0 + flicker * range_variation)
	position = _base_position + Vector3(x, y, z) * position_variation
