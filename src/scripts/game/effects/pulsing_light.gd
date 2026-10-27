class_name PulsingLightEffect
extends OmniLight3D


@export_category("Pulse")
@export_range(0.0, 16.0, 0.05) var minimum_energy: float = 1.1
@export_range(0.0, 16.0, 0.05) var maximum_energy: float = 1.9
@export_range(0.0, 4.0, 0.05) var pulse_speed: float = 1.0

var _barrier_mesh: MeshInstance3D
var _elapsed_time: float = 0.0


func _ready() -> void:
	_barrier_mesh = get_node("../DissolveSpatial") as MeshInstance3D
	_update_pulse()


func _process(delta: float) -> void:
	_elapsed_time += delta
	_update_pulse()


func _update_pulse() -> void:
	var pulse: float = sin(_elapsed_time * pulse_speed * TAU) * 0.5 + 0.5
	light_energy = lerpf(minimum_energy, maximum_energy, pulse)
	_barrier_mesh.set_instance_shader_parameter("edge_pulse", pulse)
