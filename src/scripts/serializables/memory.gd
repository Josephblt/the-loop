class_name Memory


var _description: String
var _revealed: bool = false


func _init(memory_description: String = "") -> void:
	_description = memory_description
	if _description.is_empty():
		_description = "Unknown Memory..."


func get_description() -> String:
	return _description


func is_revealed() -> bool:
	return _revealed


func reveal() -> void:
	_revealed = true


func serialize() -> Dictionary:
	return {
		"memory": {
			"description": _description,
			"revealed": _revealed,
		}
	}


func deserialize(data: Dictionary) -> void:
	var memory_data: Dictionary = data.get("memory", {})
	_description = memory_data.get("description", "")
	_revealed = memory_data.get("revealed", false)
