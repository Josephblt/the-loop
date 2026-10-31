class_name Room
extends Node3D


func setup_fire_fixtures(states: Array[FireFixtureState]) -> void:
	var fixture_nodes: Array[Node] = find_children("*", "", true, false)
	for fixture_node: Node in fixture_nodes:
		if not fixture_node is FireFixture:
			continue

		var fixture: FireFixture = fixture_node as FireFixture
		var fixture_id: String = str(get_path_to(fixture))
		var state: FireFixtureState = _find_fire_fixture_state(states, fixture_id)
		if state == null:
			state = FireFixtureState.new(fixture_id, fixture.is_lit())
			states.append(state)
		else:
			fixture.set_lit(state.is_lit)
		fixture.lit_changed.connect(state.set_lit)


func _find_fire_fixture_state(states: Array[FireFixtureState], fixture_id: String) -> FireFixtureState:
	for state: FireFixtureState in states:
		if state.fixture_id == fixture_id:
			return state
	return null
