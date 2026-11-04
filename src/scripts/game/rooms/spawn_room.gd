class_name SpawnRoom
extends Room


var _gates: Array[Gate] = []


func setup_spawn_room(gates: Array[Gate], fire_fixture_states: Array[FireFixtureState]) -> void:
	_gates.assign(gates)
	setup_room(fire_fixture_states)


func _on_activator_body_exited(_body: Node3D) -> void:
	for gate: Gate in _gates:
		gate.close()
