class_name FireFixtureStates


var spawn_room: Array[FireFixtureState] = []
var anger_room: Array[FireFixtureState] = []
var denial_room: Array[FireFixtureState] = []
var bargaining_room: Array[FireFixtureState] = []
var depression_room: Array[FireFixtureState] = []
var acceptance_room: Array[FireFixtureState] = []
var memory_rooms: Array[FireFixtureState] = []


func serialize() -> Dictionary:
	return {
		"spawn_room": _serialize_states(spawn_room),
		"anger_room": _serialize_states(anger_room),
		"denial_room": _serialize_states(denial_room),
		"bargaining_room": _serialize_states(bargaining_room),
		"depression_room": _serialize_states(depression_room),
		"acceptance_room": _serialize_states(acceptance_room),
		"memory_rooms": _serialize_states(memory_rooms),
	}


func deserialize(data: Dictionary) -> void:
	spawn_room = _deserialize_states(data.get("spawn_room", []))
	anger_room = _deserialize_states(data.get("anger_room", []))
	denial_room = _deserialize_states(data.get("denial_room", []))
	bargaining_room = _deserialize_states(data.get("bargaining_room", []))
	depression_room = _deserialize_states(data.get("depression_room", []))
	acceptance_room = _deserialize_states(data.get("acceptance_room", []))
	memory_rooms = _deserialize_states(data.get("memory_rooms", []))


func _serialize_states(states: Array[FireFixtureState]) -> Array[Dictionary]:
	var serialized_states: Array[Dictionary] = []
	for state: FireFixtureState in states:
		serialized_states.append(state.serialize())
	return serialized_states


func _deserialize_states(data: Array) -> Array[FireFixtureState]:
	var states: Array[FireFixtureState] = []
	for state_data: Dictionary in data:
		var state: FireFixtureState = FireFixtureState.new()
		state.deserialize(state_data)
		states.append(state)
	return states
