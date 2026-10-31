@abstract
class_name Room
extends Node3D


@abstract
func get_room_id() -> String


func setup_fire_fixtures(states: Array[FireFixtureState]) -> void:
	var room_id: String = get_room_id()
	var fixture_nodes: Array[Node] = find_children("*", "", true, false)
	for fixture_node: Node in fixture_nodes:
		if not fixture_node is FireFixture:
			continue

		var fixture: FireFixture = fixture_node as FireFixture
		var fixture_id: String = str(get_path_to(fixture))
		var state: FireFixtureState = _find_fire_fixture_state(states, room_id, fixture_id)
		if state == null:
			state = FireFixtureState.new(room_id, fixture_id, fixture.is_lit())
			states.append(state)
		else:
			fixture.set_lit(state.is_lit)
		fixture.lit_changed.connect(state.set_lit)


func _find_fire_fixture_state(states: Array[FireFixtureState], room_id: String, fixture_id: String) -> FireFixtureState:
	for state: FireFixtureState in states:
		if state.room_id == room_id and state.fixture_id == fixture_id:
			return state
	return null
