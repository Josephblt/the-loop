class_name PulsingLight
extends OmniLight3D


@export_range(0.0, 16.0, 0.05) var minimum_energy: float = 0.5
@export_range(0.0, 16.0, 0.05) var maximum_energy: float = 1.5
@export_range(0.0, 4.0, 0.05) var pulse_speed: float = 1.0


func _process(_delta: float) -> void:
	var elapsed_time: float = Time.get_ticks_msec() / 1000.0
	var pulse: float = sin(elapsed_time * pulse_speed * TAU) * 0.5 + 0.5
	light_energy = lerpf(minimum_energy, maximum_energy, pulse)
