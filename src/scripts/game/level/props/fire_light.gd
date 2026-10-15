@tool
class_name FireLight
extends OmniLight3D


@export_range(0.0, 1.0, 0.01) var energy_variation: float = 0.3
@export_range(0.0, 1.0, 0.01) var range_variation: float = 0.08
@export_range(0.1, 20.0, 0.1) var flicker_speed: float = 6.0

var _base_energy: float
var _base_range: float
var _elapsed_time: float
var _noise := FastNoiseLite.new()


func _ready() -> void:
	_base_energy = light_energy
	_base_range = omni_range
	_noise.seed = hash(get_path())
	_noise.frequency = 1.0


func _process(delta: float) -> void:
	if not visible:
		return

	_elapsed_time += delta * flicker_speed

	var flame_body := _noise.get_noise_1d(_elapsed_time)
	var flame_flutter := _noise.get_noise_1d(_elapsed_time * 2.7 + 100.0)
	var flicker := clampf(flame_body * 0.7 + flame_flutter * 0.3, -1.0, 1.0)

	light_energy = _base_energy * (1.0 + flicker * energy_variation)
	omni_range = _base_range * (1.0 + flicker * range_variation)
