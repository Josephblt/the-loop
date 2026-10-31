class_name Room
extends Node3D


func setup_fire_fixtures(states: Array[FireFixtureState]) -> void:
	for state: FireFixtureState in states:
		var fixture: FireFixture = get_node_or_null(NodePath(state.fixture_id)) as FireFixture
		fixture.set_lit(state.is_lit)
