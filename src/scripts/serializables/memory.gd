class_name Memory


var _description: String
var revealed: bool = false


func _init(memory_description: String = "") -> void:
	_description = memory_description


func reveal() -> String:
	revealed = true
	return _description


func serialize() -> Dictionary:
	return {
		"memory": {
			"description": _description,
			"revealed": revealed,
		}
	}


func deserialize(data: Dictionary) -> void:
	var memory_data = data.get("memory", {})
	_description = memory_data.get("description", "")
	revealed = memory_data.get("revealed", false)
