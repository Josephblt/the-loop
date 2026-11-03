class_name GameSession
extends Node

const SAVE_FILE_PATH: String = "user://the_loop_save_game.dat"
const SAVE_FILE_READABLE_PATH: String = "user://the_loop_save_game_readable.json"

const GAME_SESSION_SCENE: PackedScene = preload("res://scenes/game_session.tscn")

const STAGE_LAYOUT_PATH: StageLayout = preload("res://assets/configs/stage_layout.tres")

const SPAWN_ROOM_SCENE: PackedScene = preload("res://game/rooms/spawn_room.tscn")
const MEMORY_ROOM_SCENE: PackedScene = preload("res://game/rooms/memory_room.tscn")

const ANGER_ROOM_SCENE: PackedScene = preload("res://game/rooms/anger_room.tscn")
const DENIAL_ROOM_SCENE: PackedScene = preload("res://game/rooms/denial_room.tscn")
const BARGAINING_ROOM_SCENE: PackedScene = preload("res://game/rooms/bargaining_room.tscn")
const DEPRESSION_ROOM_SCENE: PackedScene = preload("res://game/rooms/depression_room.tscn")

const HORIZONTAL_GATE_SCENE: PackedScene = preload("res://game/switches/gate_horizontal.tscn")
const VERTICAL_GATE_SCENE: PackedScene = preload("res://game/switches/gate_vertical.tscn")

@onready var _player: Player = %Player
@onready var _stage: Node3D = %Stage

var _session_seed: int

var _story: Story
var _grief_stages_stack: GriefStagesStack
var _memories_stack: MemoriesStack
var _fire_fixture_states: FireFixtureStates
var _loop_count: int = 0

var _anger_room: GriefStageRoom
var _anger_room_gate: Gate
var _bargaining_room: GriefStageRoom
var _bargaining_room_gate: Gate
var _denial_room: GriefStageRoom
var _denial_room_gate: Gate
var _depression_room: GriefStageRoom
var _depression_room_gate: Gate
var _spawn_room: SpawnRoom
var _spawn_room_gates: Array[Gate] = []
var _memory_rooms: Array[MemoryRoom] = []



func _ready() -> void:
	load_save_data()
	_start_loop()


func _start_loop() -> void:
	_load_stage_memories()
	_add_spawn_room()
	_add_spawn_room_gates()
	# _add_grief_rooms()
	# _add_grief_room_gates()
	_add_memory_rooms()


func _load_stage_memories() -> void:
	if _memories_stack.memory_count() > 0:
		return
	var grief_stage: GriefStagesStack.GriefStages = _grief_stages_stack.peek()
	var story_stage: StoryStage = _story.get_stage(_loop_count, grief_stage)
	_memories_stack.load_story_stage(story_stage)


func _add_spawn_room() -> void:
	var fire_fixture_states: Array[FireFixtureState] = _fire_fixture_states.get_room_states(FireFixtureStates.Rooms.SPAWN)
	_spawn_room = SPAWN_ROOM_SCENE.instantiate() as SpawnRoom
	SceneRandomizer.randomize_scene(_spawn_room, _session_seed)
	_spawn_room.setup_room(fire_fixture_states)
	_stage.add_child(_spawn_room)


func _add_spawn_room_gates() -> void:
	var north_gate: Gate = _add_gate(VERTICAL_GATE_SCENE, "SpawnNorthGate", STAGE_LAYOUT_PATH.spawn_north_gate_transform)
	SceneRandomizer.randomize_scene(north_gate, _session_seed)
	_spawn_room_gates.append(north_gate)
	var south_gate: Gate = _add_gate(VERTICAL_GATE_SCENE, "SpawnSouthGate", STAGE_LAYOUT_PATH.spawn_south_gate_transform)
	SceneRandomizer.randomize_scene(south_gate, _session_seed)
	_spawn_room_gates.append(south_gate)
	var west_gate: Gate = _add_gate(HORIZONTAL_GATE_SCENE, "SpawnWestGate", STAGE_LAYOUT_PATH.spawn_west_gate_transform)
	SceneRandomizer.randomize_scene(west_gate, _session_seed)
	_spawn_room_gates.append(west_gate)
	var east_gate: Gate = _add_gate(HORIZONTAL_GATE_SCENE, "SpawnEastGate", STAGE_LAYOUT_PATH.spawn_east_gate_transform)
	SceneRandomizer.randomize_scene(east_gate, _session_seed)
	_spawn_room_gates.append(east_gate)

	_spawn_room.setup_scene(_spawn_room_gates)


func _add_memory_rooms() -> void:
	var transforms: Array[Transform3D] = STAGE_LAYOUT_PATH.memory_room_transforms(_session_seed, _memories_stack.memory_count())
	for index: int in transforms.size():
		_add_memory_room(index, transforms[index])


func _add_memory_room(index: int, room_transform: Transform3D) -> void:
	var room: MemoryRoom = MEMORY_ROOM_SCENE.instantiate() as MemoryRoom
	var memory: Memory = _memories_stack.memory_at(index)
	var room_id: String = "MemoryRoom%d" % (index + 1)
	var fire_fixture_states: Array[FireFixtureState] = _fire_fixture_states.get_room_states(FireFixtureStates.Rooms.MEMORY, room_id)
	SceneRandomizer.randomize_scene(room, _session_seed)
	room.name = room_id
	room.transform = room_transform
	room.setup_memory_room(_player, memory, fire_fixture_states)
	_memory_rooms.append(room)
	_stage.add_child(room)	
	

func _add_grief_rooms() -> void:
	_anger_room = _add_grief_room(ANGER_ROOM_SCENE, STAGE_LAYOUT_PATH.anger_room_transform, FireFixtureStates.Rooms.ANGER)
	_denial_room = _add_grief_room(DENIAL_ROOM_SCENE, STAGE_LAYOUT_PATH.denial_room_transform, FireFixtureStates.Rooms.DENIAL)
	_bargaining_room = _add_grief_room(BARGAINING_ROOM_SCENE, STAGE_LAYOUT_PATH.bargaining_room_transform, FireFixtureStates.Rooms.BARGAINING)
	_depression_room = _add_grief_room(DEPRESSION_ROOM_SCENE, STAGE_LAYOUT_PATH.depression_room_transform, FireFixtureStates.Rooms.DEPRESSION)


func _add_grief_room(scene: PackedScene, room_transform: Transform3D, room_id: FireFixtureStates.Rooms) -> Room:
	var room: Room = scene.instantiate() as Room
	room.transform = room_transform
	_stage.add_child(room)
	room.apply_fire_fixture_states(_fire_fixture_states.get_room_states(room_id))
	return room


func _add_grief_room_gates() -> void:
	_anger_room_gate = _add_gate(VERTICAL_GATE_SCENE, "AngerRoomGate", STAGE_LAYOUT_PATH.anger_room_gate_transform)
	_denial_room_gate = _add_gate(VERTICAL_GATE_SCENE, "DenialRoomGate", STAGE_LAYOUT_PATH.denial_room_gate_transform)
	_bargaining_room_gate = _add_gate(HORIZONTAL_GATE_SCENE, "BargainingRoomGate", STAGE_LAYOUT_PATH.bargaining_room_gate_transform)
	_depression_room_gate = _add_gate(HORIZONTAL_GATE_SCENE, "DepressionRoomGate", STAGE_LAYOUT_PATH.depression_room_gate_transform)
	# _anger_room_gate.setup(_grief_room_gate_starts_closed(GriefStagesStack.GriefStages.ANGER))
	# _denial_room_gate.setup(_grief_room_gate_starts_closed(GriefStagesStack.GriefStages.DENIAL))
	# _bargaining_room_gate.setup(_grief_room_gate_starts_closed(GriefStagesStack.GriefStages.BARGAINING))
	# _depression_room_gate.setup(_grief_room_gate_starts_closed(GriefStagesStack.GriefStages.DEPRESSION))


func _add_gate(scene: PackedScene, node_name: String, gate_transform: Transform3D) -> Gate:
	var gate: Gate = scene.instantiate() as Gate
	gate.name = node_name
	gate.transform = gate_transform
	_stage.add_child(gate)
	return gate


func _end_loop() -> void:
	_loop_count += 1
	update_save_data()
	get_tree().change_scene_to_packed(GAME_SESSION_SCENE)


func update_save_data() -> void:
	var data: Dictionary = {}
	data["session_seed"] = _session_seed
	data["story_path"] = _story.resource_path
	data["fire_fixture_states"] = _fire_fixture_states.serialize()
	data["grief_stages_stack"] = _grief_stages_stack.serialize()
	data["memories_stack"] = _memories_stack.serialize()
	data["loop_count"] = _loop_count

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()


func load_save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()

	var file_readable: FileAccess = FileAccess.open(SAVE_FILE_READABLE_PATH, FileAccess.WRITE)
	file_readable.store_string(JSON.stringify(data, "\t"))
	file_readable.close()

	_session_seed = data["session_seed"]
	_story = load(data["story_path"]) as Story
	_fire_fixture_states = FireFixtureStates.new()
	_fire_fixture_states.deserialize(data.get("fire_fixture_states", {}))

	_grief_stages_stack = GriefStagesStack.new(0)
	_grief_stages_stack.deserialize(data["grief_stages_stack"])

	_memories_stack = MemoriesStack.new(0)
	_memories_stack.deserialize(data["memories_stack"])
	_loop_count = data["loop_count"]


static func create_save_data() -> void:
	var session_seed: int = randi()
	var story: Story = STAGE_LAYOUT_PATH.stories[randi() % STAGE_LAYOUT_PATH.stories.size()]
	var fire_fixture_states: FireFixtureStates = FireFixtureStates.new()
	var grief_stages_stack: GriefStagesStack = GriefStagesStack.new(session_seed)
	var memories_stack: MemoriesStack = MemoriesStack.new(session_seed)

	var data: Dictionary = {}
	data["session_seed"] = session_seed
	data["story_path"] = story.resource_path
	data["fire_fixture_states"] = fire_fixture_states.serialize()
	data["grief_stages_stack"] = grief_stages_stack.serialize()
	data["memories_stack"] = memories_stack.serialize()
	data["loop_count"] = 0

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()


static func erase_save_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return

	DirAccess.remove_absolute(SAVE_FILE_PATH)
