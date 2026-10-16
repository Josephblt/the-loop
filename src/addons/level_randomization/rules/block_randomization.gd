@tool
class_name BlockRandomizationRule
extends LevelRandomizationRule


const BLOCK_SCENES_DIRECTORY: String = "res://game/level/blocks/"


func can_handle(object: Object) -> bool:
	if not object is StaticBody3D:
		return false

	var block: StaticBody3D = object as StaticBody3D
	return (
		block.scene_file_path.begins_with(BLOCK_SCENES_DIRECTORY)
		and get_target(block) != null
	)
