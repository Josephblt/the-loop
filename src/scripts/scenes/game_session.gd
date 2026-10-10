class_name GameSession
extends Node


const GAME_SESSION_SCENE_PATH = "res://scenes/game_session.tscn"
const GRID_SIZE: int = 101
const SPAWN_SIZE: int = 7

var session_seed: int

var _current_grief_stage: GriefStagesStack.GriefStages
var _grief_stages_stack: GriefStagesStack
var _memories_stack: MemoriesStack
var _loop_count: int = -1


func _init() -> void:
	self.session_seed = randi()
	_grief_stages_stack = GriefStagesStack.new(session_seed)
	_memories_stack = MemoriesStack.new(session_seed)


func _ready():
	_advance_loop()


func _advance_loop():
	_loop_count += 1
	_current_grief_stage = _grief_stages_stack.pop()
	_memories_stack.load_grief_stack(_current_grief_stage)
	GameManager.save_game(self)


static func create() -> GameSession:
	var game_session: GameSession = preload(GAME_SESSION_SCENE_PATH).instantiate()
	return game_session


static func serialize(game_session: GameSession) -> Dictionary:
	var data: Dictionary = {}
	
	data["session_seed"] = game_session.session_seed
	data["_grief_stages_stack"] = game_session._grief_stages_stack.serialize()
	data["_memories_stack"] = game_session._memories_stack.serialize()
	
	data["_loop_count"] = game_session._loop_count
	data["_current_grief_stage"] = game_session._current_grief_stage	

	return data


static func deserialize(data: Dictionary) -> GameSession:
	var game_session: GameSession = GameSession.create()
	
	game_session.session_seed = data["session_seed"]
	game_session._grief_stages_stack.deserialize(data["_grief_stages_stack"])
	game_session._memories_stack.deserialize(data["_memories_stack"])

	game_session._loop_count = data["_loop_count"]
	game_session._current_grief_stage = data["_current_grief_stage"]

	return game_session
