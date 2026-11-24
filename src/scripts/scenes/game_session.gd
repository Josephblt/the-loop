class_name GameSession
extends Node

const SAVE_FILE_PATH: String = "user://the_loop_save_game.dat"
const SAVE_FILE_READABLE_PATH: String = "user://the_loop_save_game_readable.json"
const GAME_SESSION_SCENE: PackedScene = preload("res://scenes/game_session.tscn")

@export var _stories: Stories
@export var _stage_layout: StageLayout

@onready var _acceptance_room: GriefStageRoom = %AcceptanceRoom
@onready var _anger_room: GriefStageRoom = %AngerRoom
@onready var _bargaining_room: GriefStageRoom = %BargainingRoom
@onready var _denial_room: GriefStageRoom = %DenialRoom
@onready var _depression_room: GriefStageRoom = %DepressionRoom
@onready var _maze_room: MazeRoom = %MazeRoom
@onready var _memory_rooms: MemoryRooms = %MemoryRooms


var _grief_stages_stack: GriefStagesStack
var _loop_count: int = 0
var _memories_stack: MemoriesStack
var _session_seed: int
var _story: Story


func _ready() -> void:
	load_save_data()
	_start_loop()


func _start_loop() -> void:
	_stage_layout.initialize(_session_seed, _story.memories_per_stage, _loop_count, _grief_stages_stack.peek())
	
	_load_stage_memories()	

	_acceptance_room.setup_room(_stage_layout)
	_anger_room.setup_room(_stage_layout)
	_bargaining_room.setup_room(_stage_layout)
	_denial_room.setup_room(_stage_layout)
	_depression_room.setup_room(_stage_layout)
	_maze_room.setup_room(_stage_layout)
	_memory_rooms.setup_rooms(_stage_layout)


func _load_stage_memories() -> void:
	if _memories_stack.memory_count() > 0:
		return
	var grief_stage: GriefStagesStack.GriefStages = _grief_stages_stack.peek()
	var story_stage: StoryStage = _story.get_stage(_loop_count, grief_stage)
	_memories_stack.load_story_stage(story_stage)


func update_save_data() -> void:
	var data: Dictionary = {}
	data["session_seed"] = _session_seed
	data["grief_stages_stack"] = _grief_stages_stack.serialize()
	data["memories_stack"] = _memories_stack.serialize()
	data["loop_count"] = _loop_count

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

	var file_readable: FileAccess = FileAccess.open(SAVE_FILE_READABLE_PATH, FileAccess.WRITE)
	file_readable.store_string(JSON.stringify(data, "\t"))
	file_readable.close()


func load_save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()	

	_session_seed = data["session_seed"]
	_story = _stories.get_story(_session_seed)

	_grief_stages_stack = GriefStagesStack.new(0)
	_grief_stages_stack.deserialize(data["grief_stages_stack"])

	_memories_stack = MemoriesStack.new(0)
	_memories_stack.deserialize(data["memories_stack"])
	_loop_count = data["loop_count"]


static func create_save_data() -> void:
	var session_seed: int = randi()
	var fire_fixture_states: FireFixtureStates = FireFixtureStates.new()
	var grief_stages_stack: GriefStagesStack = GriefStagesStack.new(session_seed)
	var memories_stack: MemoriesStack = MemoriesStack.new(session_seed)

	var data: Dictionary = {}
	data["session_seed"] = session_seed
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
