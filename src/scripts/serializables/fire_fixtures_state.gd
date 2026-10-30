class_name FireFixturesState


var _room_states: Dictionary[String, Dictionary] = {}


func bind_room(room_id: String, room: Node) -> void:
	var fixture_states: Dictionary = _room_states.get(room_id, {})
	_room_states[room_id] = fixture_states

	var fixture_nodes: Array[Node] = room.find_children("*", "", true, false)
	for fixture_node: Node in fixture_nodes:
		if not fixture_node is FireFixture:
			continue

		var fixture: FireFixture = fixture_node as FireFixture
		var fixture_id: String = str(room.get_path_to(fixture))
		if fixture_states.has(fixture_id):
			fixture.set_lit(bool(fixture_states[fixture_id]))
		else:
			fixture_states[fixture_id] = fixture.is_lit()
		fixture.lit_changed.connect(_on_fixture_lit_changed.bind(room_id, fixture_id))


func serialize() -> Dictionary:
	return {
		"fire_fixtures_state": {
			"rooms": _room_states,
		}
	}


func deserialize(data: Dictionary) -> void:
	_room_states.clear()
	var fire_fixtures_data: Dictionary = data.get("fire_fixtures_state", {})
	var serialized_rooms: Dictionary = fire_fixtures_data.get("rooms", {})
	for room_id: Variant in serialized_rooms:
		var serialized_fixtures: Dictionary = serialized_rooms[room_id]
		var fixture_states: Dictionary = {}
		for fixture_id: Variant in serialized_fixtures:
			fixture_states[str(fixture_id)] = bool(serialized_fixtures[fixture_id])
		_room_states[str(room_id)] = fixture_states


func _on_fixture_lit_changed(is_lit: bool, room_id: String, fixture_id: String) -> void:
	var fixture_states: Dictionary = _room_states[room_id]
	fixture_states[fixture_id] = is_lit
