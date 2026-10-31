class_name FireFixtureState


var fixture_id: String
var is_lit: bool


func _init(initial_fixture_id: String = "", initially_lit: bool = false) -> void:
	fixture_id = initial_fixture_id
	is_lit = initially_lit


func set_lit(lit: bool) -> void:
	is_lit = lit


func serialize() -> Dictionary:
	return {
		"fixture_id": fixture_id,
		"is_lit": is_lit,
	}


func deserialize(data: Dictionary) -> void:
	fixture_id = data.get("fixture_id", "")
	is_lit = data.get("is_lit", false)
