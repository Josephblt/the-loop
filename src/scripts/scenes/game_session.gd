class_name GameSession
extends Node

const SAVE_FILE_PATH = "user://the_loop_save_game.dat"

const GAME_SESSION_SCENE_PATH = "res://scenes/game_session.tscn"
const MAZE_ROOM_SCENE: PackedScene = preload("res://game/rooms/maze_room.tscn")
const SPAWN_ROOM_SCENE: PackedScene = preload("res://game/rooms/spawn_room.tscn")
const MEMORY_ROOM_SCENE: PackedScene = preload("res://game/rooms/memory_room.tscn")
const DEPRESSION_ROOM_SCENE: PackedScene = preload("res://game/rooms/depression_room.tscn")
const VERTICAL_GATE_SCENE: PackedScene = preload("res://game/switches/gate_vertical.tscn")
const HORIZONTAL_GATE_SCENE: PackedScene = preload("res://game/switches/gate_horizontal.tscn")

var session_seed: int

@export_category("Maze")
@export_range(17, 127, 2) var maze_grid_size: int = StageLayout.DEFAULT_GRID_SIZE

var _grief_stages_stack: GriefStagesStack
var _memories_stack: MemoriesStack
var _loop_count: int = -1

@onready var _stage: Node3D = %Stage


func _ready() -> void:
	_start_loop()
	var random_seeds: Array[int] = _derive_random_seeds(session_seed)
	_perform_stage_layout(StageLayout.create(random_seeds[0], maze_grid_size))


func _start_loop() -> void:
	_loop_count += 1	
	var grief_stage = _grief_stages_stack.peek()
	_memories_stack.load_grief_stack(grief_stage)
	GameSession.serialize(self)


func _end_loop() -> void:
	_grief_stages_stack.pop()
	GameSession.deserialize()


func _perform_stage_layout(layout: StageLayout) -> void:
	_add_maze(layout.maze)
	_add_scene(SPAWN_ROOM_SCENE, "SpawnRoom", layout.spawn_room_transform)
	_add_scene(DEPRESSION_ROOM_SCENE, "DepressionRoom", layout.depression_room_transform)

	for index: int in layout.memory_room_transforms.size():
		_add_scene(MEMORY_ROOM_SCENE, "MemoryRoom%d" % (index + 1), layout.memory_room_transforms[index])

	for index: int in layout.vertical_gate_transforms.size():
		_add_scene(VERTICAL_GATE_SCENE, "VerticalGate%d" % (index + 1), layout.vertical_gate_transforms[index])

	for index: int in layout.horizontal_gate_transforms.size():
		_add_scene(HORIZONTAL_GATE_SCENE, "HorizontalGate%d" % (index + 1), layout.horizontal_gate_transforms[index])


func _add_maze(maze: Maze) -> void:
	var maze_room: MazeRoom = MAZE_ROOM_SCENE.instantiate() as MazeRoom
	maze_room.maze = maze
	_stage.add_child(maze_room)


func _add_scene(scene: PackedScene, node_name: String, scene_transform: Transform3D) -> void:
	var instance: Node3D = scene.instantiate() as Node3D
	instance.name = node_name
	instance.transform = scene_transform
	_stage.add_child(instance)


static func start(random_seed: int) -> void:
	var random_seeds: Array[int] = _derive_random_seeds(random_seed)
	_create(
		random_seed,
		GriefStagesStack.new(random_seeds[1]),
		MemoriesStack.new(random_seeds[2]),
		0
	)


static func _create(random_seed: int, grief_stages_stack: GriefStagesStack, memories_stack: MemoriesStack, loop_count: int) -> void:
	var game_session: GameSession = preload(GAME_SESSION_SCENE_PATH).instantiate()
	game_session.session_seed = random_seed
	game_session._grief_stages_stack = grief_stages_stack
	game_session._memories_stack = memories_stack
	game_session._loop_count = loop_count
	
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	scene_tree.current_scene.queue_free()
	scene_tree.root.add_child(game_session)
	scene_tree.current_scene = game_session


static func _derive_random_seeds(random_seed: int) -> Array[int]:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = random_seed
	return [randomizer.randi(), randomizer.randi(), randomizer.randi()]


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

	GameSession._create(
		random_seed,
		grief_stages_stack,
		memories_stack,
		loop_count
	)
