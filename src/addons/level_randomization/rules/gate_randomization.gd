@tool
class_name GateRandomizationRule
extends LevelRandomizationRule


const GATE_SCENE_PATH: String = "res://game/level/walls/gate.tscn"
const INVERSION_POSITION_OFFSET: Vector3 = Vector3(0.0, 0.0, 0.6)


func can_handle(object: Object) -> bool:
	if not object is StaticBody3D:
		return false

	var gate: StaticBody3D = object as StaticBody3D
	return (
		gate.scene_file_path == GATE_SCENE_PATH
		and get_target(gate) != null
	)


func _get_inversion_position_offset() -> Vector3:
	return INVERSION_POSITION_OFFSET
