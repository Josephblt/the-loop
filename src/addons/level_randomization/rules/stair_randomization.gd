@tool
class_name StairRandomizationRule
extends LevelRandomizationRule


const STAIR_SCENES_DIRECTORY: String = "res://game/level/stairs/"


func can_handle(object: Object) -> bool:
	if not object is StaticBody3D:
		return false

	var stair: StaticBody3D = object as StaticBody3D
	return (
		stair.scene_file_path.begins_with(STAIR_SCENES_DIRECTORY)
		and get_target(stair) != null
	)


func _can_invert() -> bool:
	return false
