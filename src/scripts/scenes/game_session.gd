class_name GameSession
extends Node

const SAVE_FILE_PATH = "user://the_loop_save_game.dat"

const GAME_SESSION_SCENE_PATH = "res://scenes/game_session.tscn"
const MAZE_ROOM_SIZE: int = 101
const MEMORY_ROOM_SIZE: int = 3
const STAGE_ROOM_SIZE: int = 7

var session_seed: int

var _grief_stages_stack: GriefStagesStack
var _memories_stack: MemoriesStack
var _loop_count: int = -1


func _ready():
	print("Ready method")
	_start_loop()


func _start_loop():	
	_loop_count += 1	
	var grief_stage = _grief_stages_stack.peek()
	_memories_stack.load_grief_stack(grief_stage)
	GameSession.serialize(self)


func _end_loop():
	_grief_stages_stack.pop()
	GameSession.deserialize()


static func create(random_seed: int, grief_stages_stack: GriefStagesStack, memories_stack: MemoriesStack, loop_count: int) -> void:
	var game_session: GameSession = preload(GAME_SESSION_SCENE_PATH).instantiate()
	print("Instantiate method")
	game_session.session_seed = random_seed
	print("Session seed set")
	game_session._grief_stages_stack = grief_stages_stack
	game_session._memories_stack = memories_stack
	game_session._loop_count = loop_count
	
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	scene_tree.current_scene.queue_free()
	scene_tree.root.add_child(game_session)
	scene_tree.current_scene = game_session


static func serialize(game_session: GameSession) -> void:
	var data: Dictionary = {}
	
	data["session_seed"] = game_session.session_seed
	data["_grief_stages_stack"] = game_session._grief_stages_stack.serialize()
	data["_memories_stack"] = game_session._memories_stack.serialize()
	data["_loop_count"] = game_session._loop_count
	
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()


static func deserialize() -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()

	var random_seed: int = data["session_seed"]
	var grief_stages_stack: GriefStagesStack = data["_grief_stages_stack"]
	var memories_stack: MemoriesStack = data["_memories_stack"]
	var loop_count: int = data["_loop_count"]

	GameSession.create(
		random_seed,
		grief_stages_stack,
		memories_stack,
		loop_count
	)
