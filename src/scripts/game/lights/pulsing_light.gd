class_name PulsingLightEffect
extends OmniLight3D


@export_category("Pulse")
@export_range(0.0, 16.0, 0.05) var minimum_energy: float = 1.1
@export_range(0.0, 16.0, 0.05) var maximum_energy: float = 1.9
@export_range(0.0, 4.0, 0.05) var pulse_speed: float = 1.0

func _ready() -> void:
	var barrier_mesh: MeshInstance3D = get_node("../DissolveSpatial") as MeshInstance3D
	barrier_mesh.set_instance_shader_parameter("pulse_speed", pulse_speed)
	_update_pulse()


func _process(_delta: float) -> void:
	_update_pulse()


func _update_pulse() -> void:
	var elapsed_time: float = Time.get_ticks_msec() / 1000.0
	var pulse: float = sin(elapsed_time * pulse_speed * TAU) * 0.5 + 0.5
	light_energy = lerpf(minimum_energy, maximum_energy, pulse)
