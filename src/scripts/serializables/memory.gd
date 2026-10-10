class_name Memory


var description: String
var revealed: bool = false


func _init(memory_description: String = "") -> void:
	description = memory_description


func reveal() -> Memory:
	revealed = true
	return self


func serialize() -> Dictionary:
	return {
		"memory": {
			"description": description,
			"revealed": revealed,
		}
	}


func deserialize(data: Dictionary) -> void:
	var memory_data = data.get("memory", {})
	description = memory_data.get("description", "")
	revealed = memory_data.get("revealed", false)
