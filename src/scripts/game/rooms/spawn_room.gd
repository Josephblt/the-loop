class_name SpawnRoom
extends Room


var _gates: Array[Gate] = []


func setup_gates(gates: Array[Gate]) -> void:
	_gates.assign(gates)


func _on_activator_body_exited(body: Node3D) -> void:
	if not body is Player:
		return

	for gate: Gate in _gates:
		gate.close()
