extends SceneTree


func _initialize() -> void:
	var project: String = FileAccess.get_file_as_string("res://project.godot")
	var gate_scene: String = FileAccess.get_file_as_string("res://game/switches/gate.tscn")
	var player_scene: String = FileAccess.get_file_as_string("res://game/actors/player.tscn")
	var inline_flow_script: String = FileAccess.get_file_as_string("res://scripts/game/effects/inline_flow.gd")

	var is_valid: bool = true
	is_valid = _contains(project, "3d_render/layer_3=\"Fire\"") and is_valid
	is_valid = _contains(project, "3d_render/layer_4=\"InlineFlow\"") and is_valid
	is_valid = _contains(project, "3d_render/layer_5=\"DissolveSpatial\"") and is_valid
	is_valid = _contains(gate_scene, "layers = 16") and is_valid
	is_valid = _contains(player_scene, "cull_mask = 9") and is_valid
	is_valid = _contains(inline_flow_script, "inline_flow_mask.layers = 8") and is_valid
	quit(0 if is_valid else 1)


func _contains(source: String, expected: String) -> bool:
	if source.contains(expected):
		return true

	printerr("Missing render contract: %s" % expected)
	return false
