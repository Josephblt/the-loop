class_name PulsingLightEffect
extends OmniLight3D


@export_category("Pulse")
@export_range(0.0, 16.0, 0.05) var minimum_energy: float = 1.1
@export_range(0.0, 16.0, 0.05) var maximum_energy: float = 1.9
@export_range(0.05, 10.0, 0.05) var minimum_duration: float = 0.6
@export_range(0.05, 10.0, 0.05) var maximum_duration: float = 1.4
@export var random_seed: int = 0

var _random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
var _pulse_tween: Tween


func _ready() -> void:
	if random_seed == 0:
		_random_number_generator.randomize()
	else:
		_random_number_generator.seed = random_seed

	_pulse_to_random_energy()


func _pulse_to_random_energy() -> void:
	var lower_energy: float = minf(minimum_energy, maximum_energy)
	var upper_energy: float = maxf(minimum_energy, maximum_energy)
	var lower_duration: float = maxf(minf(minimum_duration, maximum_duration), 0.05)
	var upper_duration: float = maxf(maxf(minimum_duration, maximum_duration), lower_duration)
	var target_energy: float = _random_number_generator.randf_range(lower_energy, upper_energy)
	var duration: float = _random_number_generator.randf_range(lower_duration, upper_duration)

	_pulse_tween = create_tween()
	_pulse_tween.set_trans(Tween.TRANS_SINE)
	_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(self, "light_energy", target_energy, duration)
	_pulse_tween.finished.connect(_pulse_to_random_energy)
