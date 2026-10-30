class_name FireFixtureState


var room_id: String
var fixture_id: String
var is_lit: bool


func _init(initial_room_id: String = "", initial_fixture_id: String = "", initially_lit: bool = false) -> void:
	room_id = initial_room_id
	fixture_id = initial_fixture_id
	is_lit = initially_lit


func set_lit(lit: bool) -> void:
	is_lit = lit


func serialize() -> Dictionary:
	return {
		"room_id": room_id,
		"fixture_id": fixture_id,
		"is_lit": is_lit,
	}


func deserialize(data: Dictionary) -> void:
	room_id = data.get("room_id", "")
	fixture_id = data.get("fixture_id", "")
	is_lit = data.get("is_lit", false)
