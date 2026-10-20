class_name Memory


var _description: String
var _fire_fixture_states: Dictionary[String, bool] = {}
var revealed: bool = false


func _init(memory_description: String = "") -> void:
	_description = memory_description
	if _description.is_empty():
		_description = "Unknown Memory..."


func reveal() -> String:
	revealed = true
	return _description


func has_fire_fixture_state(fixture_path: String) -> bool:
	return _fire_fixture_states.has(fixture_path)


func get_fire_fixture_state(fixture_path: String) -> bool:
	return _fire_fixture_states.get(fixture_path, false)


func set_fire_fixture_state(fixture_path: String, is_lit: bool) -> void:
	_fire_fixture_states[fixture_path] = is_lit


func serialize() -> Dictionary:
	return {
		"memory": {
			"description": _description,
			"revealed": revealed,
			"fire_fixture_states": _fire_fixture_states,
		}
	}


func deserialize(data: Dictionary) -> void:
	var memory_data: Dictionary = data.get("memory", {})
	_description = memory_data.get("description", "")
	revealed = memory_data.get("revealed", false)

	_fire_fixture_states.clear()
	var serialized_states: Dictionary = memory_data.get("fire_fixture_states", {})
	for fixture_path: Variant in serialized_states:
		_fire_fixture_states[str(fixture_path)] = bool(serialized_states[fixture_path])
