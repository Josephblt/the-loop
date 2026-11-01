class_name FireFixtureState


var fixture_id: NodePath
var is_lit: bool


func _init(initial_fixture_id: NodePath = NodePath(), initially_lit: bool = false) -> void:
	fixture_id = initial_fixture_id
	is_lit = initially_lit


func serialize() -> Dictionary:
	return {
		"fixture_id": fixture_id,
		"is_lit": is_lit,
	}


func deserialize(data: Dictionary) -> void:
	fixture_id = NodePath(str(data.get("fixture_id", "")))
	is_lit = data.get("is_lit", false)
