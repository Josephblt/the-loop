class_name GameSession
extends Node

const GAME_SESSION_SCENE: PackedScene = preload("res://scenes/game_session.tscn")
const MESSAGE_TIP: String = "Interact to close..."
const SAVE_FILE_PATH: String = "user://the_loop_save_game.dat"
const SAVE_FILE_READABLE_PATH: String = "user://the_loop_save_game_readable.json"

@export var _stories: Stories
@export var _stage_layout: StageLayout

@onready var _player: Player = %Player

@onready var _acceptance_room: GriefStageRoom = %AcceptanceRoom
@onready var _anger_room: GriefStageRoom = %AngerRoom
@onready var _bargaining_room: GriefStageRoom = %BargainingRoom
@onready var _denial_room: GriefStageRoom = %DenialRoom
@onready var _depression_room: GriefStageRoom = %DepressionRoom
@onready var _maze_room: MazeRoom = %MazeRoom
@onready var _memory_rooms: MemoryRooms = %MemoryRooms

@onready var _message: Message = %Message
@onready var _debug_overlay: DebugOverlay = $UI/DebugOverlay


var _grief_stages_stack: GriefStagesStack
var _loop_count: int = 0
var _session_seed: int
var _story: Story


func _ready() -> void:
	var data: Dictionary = load_save_data()
	_session_seed = data["session_seed"]

	_story = _stories.get_story(_session_seed)

	_grief_stages_stack = GriefStagesStack.new(0)
	if data["grief_stages_stack"].is_empty():
		_grief_stages_stack = GriefStagesStack.new(_session_seed)
	else:
		_grief_stages_stack.deserialize(data["grief_stages_stack"])

	_loop_count = data["loop_count"]

	_stage_layout.initialize(_session_seed, _story.memories_per_stage, _loop_count, _grief_stages_stack.peek())

	_acceptance_room.setup_room(_stage_layout, data["acceptance_room"])
	_anger_room.setup_room(_stage_layout, data["anger_room"])
	_bargaining_room.setup_room(_stage_layout, data["bargaining_room"])
	_denial_room.setup_room(_stage_layout, data["denial_room"])
	_depression_room.setup_room(_stage_layout, data["depression_room"])
	_maze_room.setup_room(_stage_layout, _player, _grief_stages_stack.peek())
	_memory_rooms.setup_rooms(_stage_layout)
	var enemy_behaviour: EnemyBehaviour = _maze_room.get_enemy_behaviour()
	if enemy_behaviour != null:
		enemy_behaviour.state_changed.connect(_debug_overlay.set_enemy_state)
		_debug_overlay.set_enemy_state(enemy_behaviour.state)


func update_save_data() -> void:
	var data: Dictionary = {}
	data["session_seed"] = _session_seed
	data["loop_count"] = _loop_count
	data["grief_stages_stack"] = _grief_stages_stack.serialize()
	data["acceptance_room"] = _acceptance_room.serialize_grief_stage_room()
	data["anger_room"] = _anger_room.serialize_grief_stage_room()
	data["bargaining_room"] = _bargaining_room.serialize_grief_stage_room()
	data["denial_room"] = _denial_room.serialize_grief_stage_room()
	data["depression_room"] = _depression_room.serialize_grief_stage_room()

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

	var file_readable: FileAccess = FileAccess.open(SAVE_FILE_READABLE_PATH, FileAccess.WRITE)
	file_readable.store_string(JSON.stringify(data, "\t"))
	file_readable.close()


func load_save_data() -> Dictionary:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()

	return data


static func create_save_data() -> void:
	var session_seed: int = randi()

	var data: Dictionary = {}
	data["session_seed"] = session_seed
	data["loop_count"] = 0
	data["grief_stages_stack"] = {}
	data["acceptance_room"] = {}
	data["anger_room"] = {}
	data["bargaining_room"] = {}
	data["denial_room"] = {}
	data["depression_room"] = {}

	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(data)
	file.close()

	var file_readable: FileAccess = FileAccess.open(SAVE_FILE_READABLE_PATH, FileAccess.WRITE)
	file_readable.store_string(JSON.stringify(data, "\t"))
	file_readable.close()


static func erase_save_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return

	DirAccess.remove_absolute(SAVE_FILE_PATH)


func _on_acceptance_room_chest_opened() -> void:
	pass # Replace with function body.


func _on_acceptance_room_player_entered(_grief_stage_room: GriefStageRoom) -> void:
	pass


func _on_acceptance_room_player_exited(_grief_stage_room: GriefStageRoom) -> void:
	_acceptance_room.close_gates(false)
	_maze_room.enable_enemy_ai()


func _on_grief_stage_room_chest_opened() -> void:
	var story_stage: StoryStage = _story.get_stage(_loop_count, _grief_stages_stack.peek())
	var memory: String = story_stage.closing_memory

	_message.setup_message(memory)
	_message.setup_tip(MESSAGE_TIP)
	_message.show_message()


func _on_grief_stage_room_player_entered(grief_stage_room: GriefStageRoom) -> void:
	grief_stage_room.close_gates(false)
	grief_stage_room.materialize_chest()
	grief_stage_room.enemy_appear()


func _on_memory_rooms_all_chests_opened() -> void:
	var grief_stage: GriefStagesStack.GriefStages = _grief_stages_stack.peek()
	match grief_stage:
		GriefStagesStack.GriefStages.ACCEPTANCE:
			_acceptance_room.open_gates(false)
		GriefStagesStack.GriefStages.ANGER:
			_anger_room.open_gates(false)
		GriefStagesStack.GriefStages.BARGAINING:
			_bargaining_room.open_gates(false)
		GriefStagesStack.GriefStages.DEPRESSION:
			_depression_room.open_gates(false)
		GriefStagesStack.GriefStages.DENIAL:
			_denial_room.open_gates(false)


func _on_memory_rooms_chest_opened(chest_index: int) -> void:
	var story_stage: StoryStage = _story.get_stage(_loop_count, _grief_stages_stack.peek())
	var memory: String = story_stage.maze_memories[chest_index]

	_message.setup_message(memory)
	_message.setup_tip(MESSAGE_TIP)
	_message.show_message()


func _on_message_message_shown() -> void:
	_player.pause()


func _on_message_message_hidden() -> void:
	_player.resume()
