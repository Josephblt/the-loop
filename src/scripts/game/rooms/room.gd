class_name Room
extends Node3D


var _fire_fixtures_states: Array[FireFixtureState]


func _ready() -> void:
	_setup_fire_fixtures()


func setup_room(fire_fixtures_states: Array[FireFixtureState]) -> void:
	_fire_fixtures_states = fire_fixtures_states


func ignite_fire_fixtures() -> void:
	pass


func extinguish_fire_fixtures() -> void:
	pass


func _setup_fire_fixtures() -> void:
	for state: FireFixtureState in _fire_fixtures_states:
		var fixture: FireFixture = get_node(state.fixture_id) as FireFixture
		fixture.set_lit(state.is_lit)


func _find_fire_fixture_state(fire_fixture: FireFixture) -> FireFixtureState:
	for fire_fixture_state: FireFixtureState in _fire_fixtures_states:
		if fire_fixture_state.fixture_id == fire_fixture.get_path():
			return fire_fixture_state

	return null


func _on_fire_fixture_interaction_triggered(interactable: Interactable) -> void:
	var fixture: FireFixture = interactable as FireFixture
	var fixture_state: FireFixtureState = _find_fire_fixture_state(fixture)
		
	if fixture_state:
		fixture_state.is_lit = fixture.is_lit()
	else:
		_fire_fixtures_states.append(FireFixtureState.new(fixture.get_path(), fixture.is_lit()))