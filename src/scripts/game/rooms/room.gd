class_name Room
extends Node3D


func apply_fire_fixture_states(states: Array[FireFixtureState]) -> void:
	for state: FireFixtureState in states:
		var fixture: FireFixture = get_node_or_null(state.fixture_id) as FireFixture
		fixture.set_lit(state.is_lit)


func capture_fire_fixture_states() -> Array[FireFixtureState]:
	var states: Array[FireFixtureState] = []
	var nodes: Array[Node] = find_children("*", "", true, false)
	var lit_fixtures: int = 0
	for node: Node in nodes:
		if not node is FireFixture:
			continue
		var fixture: FireFixture = node as FireFixture
		if fixture.is_lit():
			lit_fixtures += 1
		states.append(FireFixtureState.new(get_path_to(fixture), fixture.is_lit()))
	print("Lit fixtures: %d" % lit_fixtures)
	return states
