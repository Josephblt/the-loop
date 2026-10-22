extends SceneTree


func _initialize() -> void:
	var inline_flow_resource: Shader = load("res://shaders/inline_flow.gdshader") as Shader
	var inline_flow_mask_resource: Shader = load("res://shaders/inline_flow_mask.gdshader") as Shader
	var inline_flow: String = FileAccess.get_file_as_string("res://shaders/inline_flow.gdshader")
	var inline_flow_mask: String = FileAccess.get_file_as_string("res://shaders/inline_flow_mask.gdshader")
	var is_valid: bool = true

	is_valid = _is_loaded(inline_flow_resource, "inline_flow.gdshader") and is_valid
	is_valid = _is_loaded(inline_flow_mask_resource, "inline_flow_mask.gdshader") and is_valid
	is_valid = _contains(inline_flow_mask, "varying vec3 local_position;") and is_valid
	is_valid = _contains(inline_flow_mask, "length(dFdx(local_position))") and is_valid
	is_valid = _contains(inline_flow_mask, "length(dFdy(local_position))") and is_valid
	is_valid = _contains(inline_flow, "core_width / local_pixel_size") and is_valid
	is_valid = _contains(inline_flow, "halo_width / local_pixel_size") and is_valid
	is_valid = _excludes(inline_flow, "TEXTURE_PIXEL_SIZE * core_width") and is_valid
	is_valid = _excludes(inline_flow, "TEXTURE_PIXEL_SIZE * halo_width") and is_valid
	quit(0 if is_valid else 1)


func _is_loaded(shader: Shader, shader_name: String) -> bool:
	if shader != null:
		return true

	printerr("Shader failed to load: %s" % shader_name)
	return false


func _contains(source: String, expected: String) -> bool:
	if source.contains(expected):
		return true

	printerr("Missing portal-local width contract: %s" % expected)
	return false


func _excludes(source: String, rejected: String) -> bool:
	if not source.contains(rejected):
		return true

	printerr("Screen-space width contract remains: %s" % rejected)
	return false
