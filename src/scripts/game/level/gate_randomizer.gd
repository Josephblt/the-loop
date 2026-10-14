@tool
class_name GateRandomizer
extends LevelRandomizer


func _randomize_inversion() -> void:
	super._randomize_inversion()

	if _inverted:
		%MeshInstance3D.position.z += 0.6