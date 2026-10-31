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


func deserialize(data: Variant) -> void:
	_clear()
	if data is Array:
		_deserialize_legacy_states(data as Array)
		return
	if not data is Dictionary:
		return

	var serialized_states: Dictionary = data as Dictionary
	spawn_room = _deserialize_states(serialized_states.get("spawn_room", []))
	anger_room = _deserialize_states(serialized_states.get("anger_room", []))
	denial_room = _deserialize_states(serialized_states.get("denial_room", []))
	bargaining_room = _deserialize_states(serialized_states.get("bargaining_room", []))
	depression_room = _deserialize_states(serialized_states.get("depression_room", []))
	acceptance_room = _deserialize_states(serialized_states.get("acceptance_room", []))
	memory_rooms = _deserialize_states(serialized_states.get("memory_rooms", []))


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


func _deserialize_legacy_states(data: Array) -> void:
	for state_data: Dictionary in data:
		var state: FireFixtureState = FireFixtureState.new()
		state.deserialize(state_data)
		_states_for_room(state.room_id).append(state)


func _states_for_room(room_id: String) -> Array[FireFixtureState]:
	match room_id:
		"spawn_room":
			return spawn_room
		"anger_room":
			return anger_room
		"denial_room":
			return denial_room
		"bargaining_room":
			return bargaining_room
		"depression_room":
			return depression_room
		"acceptance_room":
			return acceptance_room
		_:
			return memory_rooms


func _clear() -> void:
	spawn_room.clear()
	anger_room.clear()
	denial_room.clear()
	bargaining_room.clear()
	depression_room.clear()
	acceptance_room.clear()
	memory_rooms.clear()
