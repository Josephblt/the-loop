class_name SpawnRoom
extends Room


var _gates: Array[Gate] = []


func setup_scene(gates: Array[Gate]) -> void:
	_gates.assign(gates)


func _on_activator_body_exited(_body: Node3D) -> void:
	for gate: Gate in _gates:
		gate.close()
