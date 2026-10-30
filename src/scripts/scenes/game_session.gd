class_name GameSession
extends Node

const GAME_SESSION_SCENE: PackedScene = preload("res://scenes/game_session.tscn")
const SAVE_FILE_PATH: String = "user://the_loop_save_game.dat"
const STAGE_LAYOUT_PATH: StageLayout = preload("res://assets/configs/stage_layout.tres")

var _grief_stages_stack: GriefStagesStack
var _loop_count: int = 0
var _memories_stack: MemoriesStack
var _session_seed: int
var _story: Story


func _ready() -> void:
	load_save_data()
	_start_loop()


func _start_loop() -> void:
	pass


func _end_loop() -> void:
	_loop_count += 1
	update_save_data()
	get_tree().change_scene_to_packed(GAME_SESSION_SCENE)


func update_save_data() -> void:
	var data: Dictionary = {}
	data["session_seed"] = _session_seed
	data["story_path"] = _story.resource_path
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

	_grief_stages_stack = GriefStagesStack.new(0)
	_grief_stages_stack.deserialize(data["grief_stages_stack"])

	_memories_stack = MemoriesStack.new(0)
	_memories_stack.deserialize(data["memories_stack"])
	_loop_count = data["loop_count"]


static func create_save_data() -> void:
	var session_seed: int = randi()
	var story: Story = STAGE_LAYOUT_PATH.stories[randi() % STAGE_LAYOUT_PATH.stories.size()]
	var grief_stages_stack: GriefStagesStack = GriefStagesStack.new(session_seed)
	var memories_stack: MemoriesStack = MemoriesStack.new(session_seed)

	var data: Dictionary = {}
	data["session_seed"] = session_seed
	data["story_path"] = story.resource_path
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
