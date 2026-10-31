class_name GameSession
extends Node

const GAME_SESSION_SCENE: PackedScene = preload("res://scenes/game_session.tscn")
const HORIZONTAL_GATE_SCENE: PackedScene = preload("res://game/switches/gate_horizontal.tscn")
const SAVE_FILE_PATH: String = "user://the_loop_save_game.dat"
const SPAWN_ROOM_SCENE: PackedScene = preload("res://game/rooms/spawn_room.tscn")
const STAGE_LAYOUT_PATH: StageLayout = preload("res://assets/configs/stage_layout.tres")
const VERTICAL_GATE_SCENE: PackedScene = preload("res://game/switches/gate_vertical.tscn")

@onready var _stage: Node3D = %Stage

var _grief_stages_stack: GriefStagesStack
var _fire_fixture_states: FireFixtureStates
var _loop_count: int = 0
var _memories_stack: MemoriesStack
var _session_seed: int
var _spawn_room_gates: Array[Gate] = []
var _story: Story


func _ready() -> void:
	load_save_data()
	_start_loop()


func _start_loop() -> void:
	_add_spawn_room()
	_add_spawn_room_gates()


func _add_spawn_room() -> void:
	var spawn_room: SpawnRoom = SPAWN_ROOM_SCENE.instantiate() as SpawnRoom
	spawn_room.room_deactivated.connect(_activate_spawn_room_gates, CONNECT_ONE_SHOT)
	_stage.add_child(spawn_room)
	spawn_room.setup_fire_fixtures("spawn_room", _fire_fixture_states.spawn_room)


func _add_spawn_room_gates() -> void:
	_spawn_room_gates.append(_add_gate(VERTICAL_GATE_SCENE, "SpawnNorthGate", STAGE_LAYOUT_PATH.spawn_north_gate_transform))
	_spawn_room_gates.append(_add_gate(VERTICAL_GATE_SCENE, "SpawnSouthGate", STAGE_LAYOUT_PATH.spawn_south_gate_transform))
	_spawn_room_gates.append(_add_gate(HORIZONTAL_GATE_SCENE, "SpawnWestGate", STAGE_LAYOUT_PATH.spawn_west_gate_transform))
	_spawn_room_gates.append(_add_gate(HORIZONTAL_GATE_SCENE, "SpawnEastGate", STAGE_LAYOUT_PATH.spawn_east_gate_transform))


func _add_gate(scene: PackedScene, node_name: String, gate_transform: Transform3D) -> Gate:
	var gate: Gate = scene.instantiate() as Gate
	gate.name = node_name
	gate.transform = gate_transform
	_stage.add_child(gate)
	return gate


func _activate_spawn_room_gates() -> void:
	for gate: Gate in _spawn_room_gates:
		gate.activate()


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
