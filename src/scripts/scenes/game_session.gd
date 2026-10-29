class_name GameSession
extends Node

const SAVE_FILE_PATH = "user://the_loop_save_game.dat"

@export var story: Story

var _grief_stages_stack: GriefStagesStack
var _loop_count: int = -1
var _memories_stack: MemoriesStack
var _session_seed: int


func _ready() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		load_save_data()
		return

	_start_new_session()


func _start_new_session() -> void:
	_session_seed = randi()
	_grief_stages_stack = GriefStagesStack.new(_session_seed)
	_memories_stack = MemoriesStack.new(_session_seed)
	_start_loop()


func _start_loop() -> void:
	_loop_count += 1
	update_save_data()


func _end_loop() -> void:
	_grief_stages_stack.pop()
	load_save_data()


func update_save_data() -> void:
	var data: Dictionary = {}
	data["session_seed"] = _session_seed
	data["story_path"] = story.resource_path
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
	story = load(data["story_path"]) as Story

	_grief_stages_stack = GriefStagesStack.new(0)
	_grief_stages_stack.deserialize(data["grief_stages_stack"])

	_memories_stack = MemoriesStack.new(0)
	_memories_stack.deserialize(data["memories_stack"])
	_loop_count = data["loop_count"]


static func erase_save_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return

	DirAccess.remove_absolute(SAVE_FILE_PATH)
