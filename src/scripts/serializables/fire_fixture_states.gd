class_name FireFixtureStates


enum Rooms {
	SPAWN,
	ANGER,
	DENIAL,
	BARGAINING,
	DEPRESSION,
	ACCEPTANCE,
	MEMORY,
}

var _spawn_room: Array[FireFixtureState] = []
var _anger_room: Array[FireFixtureState] = []
var _denial_room: Array[FireFixtureState] = []
var _bargaining_room: Array[FireFixtureState] = []
var _depression_room: Array[FireFixtureState] = []
var _acceptance_room: Array[FireFixtureState] = []
var _memory_rooms: Dictionary = {}


func get_room_states(room: Rooms, memory_room_id: String = "") -> Array[FireFixtureState]:
	match room:
		Rooms.SPAWN:
			return _spawn_room
		Rooms.ANGER:
			return _anger_room
		Rooms.DENIAL:
			return _denial_room
		Rooms.BARGAINING:
			return _bargaining_room
		Rooms.DEPRESSION:
			return _depression_room
		Rooms.ACCEPTANCE:
			return _acceptance_room
		Rooms.MEMORY:
			return _get_memory_room_states(memory_room_id)

	var states: Array[FireFixtureState] = []
	return states


func _get_memory_room_states(room_id: String) -> Array[FireFixtureState]:
	assert(not room_id.is_empty(), "Memory room ID cannot be empty.")
	if not _memory_rooms.has(room_id):
		var states: Array[FireFixtureState] = []
		_memory_rooms[room_id] = states
	return _memory_rooms[room_id]


func serialize() -> Dictionary:
	return {
		"spawn_room": _serialize_states(_spawn_room),
		"anger_room": _serialize_states(_anger_room),
		"denial_room": _serialize_states(_denial_room),
		"bargaining_room": _serialize_states(_bargaining_room),
		"depression_room": _serialize_states(_depression_room),
		"acceptance_room": _serialize_states(_acceptance_room),
		"memory_rooms": _serialize_memory_rooms(),
	}


func deserialize(data: Dictionary) -> void:
	_spawn_room = _deserialize_states(data.get("spawn_room", []))
	_anger_room = _deserialize_states(data.get("anger_room", []))
	_denial_room = _deserialize_states(data.get("denial_room", []))
	_bargaining_room = _deserialize_states(data.get("bargaining_room", []))
	_depression_room = _deserialize_states(data.get("depression_room", []))
	_acceptance_room = _deserialize_states(data.get("acceptance_room", []))
	_deserialize_memory_rooms(data.get("memory_rooms", {}))


func _serialize_memory_rooms() -> Dictionary:
	var serialized_rooms: Dictionary = {}
	for room_id: String in _memory_rooms:
		serialized_rooms[room_id] = _serialize_states(_memory_rooms[room_id])
	return serialized_rooms


func _deserialize_memory_rooms(data: Dictionary) -> void:
	_memory_rooms.clear()
	for room_id: String in data:
		_memory_rooms[room_id] = _deserialize_states(data[room_id])


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
