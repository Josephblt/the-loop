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
const QUICK_TEST_STAGE: GriefStagesStack.GriefStages = GriefStagesStack.GriefStages.DEPRESSION


@onready var _player: Player = %Player
@onready var _stage: Node3D = %Stage

var _grief_stages_stack: GriefStagesStack
var _load_existing_loop: bool = false
var _memories_stack: MemoriesStack
var _loop_count: int = -1
var _session_seed: int
var _story: Story



func _ready() -> void:
	if not _load_existing_loop:
		_start_loop()
	var layout: StageLayout = StageLayout.create(_session_seed, StageLayout.DEFAULT_GRID_SIZE, _memories_stack.memory_count())
	_perform_stage_layout(layout)


func _start_loop() -> void:
	_loop_count += 1
	var story_stage: StoryStage = _story.get_stage(_loop_count, QUICK_TEST_STAGE)
	_memories_stack.load_story_stage(story_stage)
	GameSession.serialize(self)


func _end_loop() -> void:
	_grief_stages_stack.pop()
	GameSession.deserialize()


func _perform_stage_layout(layout: StageLayout) -> void:
	_add_maze(layout.maze)
	_add_scene(SPAWN_ROOM_SCENE, "SpawnRoom", layout.spawn_room_transform)
	_add_depression_room(layout.depression_room_transform)

	for index: int in layout.memory_room_transforms.size():
		_add_memory_room(index, layout.memory_room_transforms[index])

	for index: int in layout.vertical_gate_transforms.size():
		_add_scene(VERTICAL_GATE_SCENE, "VerticalGate%d" % (index + 1), layout.vertical_gate_transforms[index])

	for index: int in layout.horizontal_gate_transforms.size():
		_add_scene(HORIZONTAL_GATE_SCENE, "HorizontalGate%d" % (index + 1), layout.horizontal_gate_transforms[index])


func _add_maze(maze: Maze) -> void:
	var maze_room: MazeRoom = MAZE_ROOM_SCENE.instantiate() as MazeRoom
	maze_room.maze = maze
	_add_instance(maze_room, "MazeRoom", Transform3D.IDENTITY)


func _add_depression_room(scene_transform: Transform3D) -> void:
	var depression_room: DepressionRoom = DEPRESSION_ROOM_SCENE.instantiate() as DepressionRoom
	depression_room.setup_scene(_player, _memories_stack.closing_memory())
	_add_instance(depression_room, "DepressionRoom", scene_transform)


func _add_memory_room(index: int, scene_transform: Transform3D) -> void:
	var memory_room: MemoryRoom = MEMORY_ROOM_SCENE.instantiate() as MemoryRoom
	memory_room.setup_scene(_player, _memories_stack.memory_at(index))
	_add_instance(memory_room, "MemoryRoom%d" % (index + 1), scene_transform)


func _add_scene(scene: PackedScene, node_name: String, scene_transform: Transform3D) -> void:
	var instance: Node3D = scene.instantiate() as Node3D
	_add_instance(instance, node_name, scene_transform)


func _add_instance(instance: Node3D, node_name: String, scene_transform: Transform3D) -> void:
	instance.name = node_name
	instance.transform = scene_transform
	_stage.add_child(instance)
	SceneRandomizer.randomize_scene(instance, _session_seed)


static func start(random_seed: int, selected_story: Story) -> void:
	_create(
		random_seed,
		selected_story,
		GriefStagesStack.new(random_seed),
		MemoriesStack.new(random_seed),
		-1,
		false
	)


static func _create(
	random_seed: int,
	selected_story: Story,
	grief_stages_stack: GriefStagesStack,
	memories_stack: MemoriesStack,
	loop_count: int,
	load_existing_loop: bool
) -> void:
	var game_session: GameSession = preload(GAME_SESSION_SCENE_PATH).instantiate()
	game_session._grief_stages_stack = grief_stages_stack
	game_session._memories_stack = memories_stack
	game_session._loop_count = loop_count
	game_session._load_existing_loop = load_existing_loop
	game_session._session_seed = random_seed
	game_session._story = selected_story
	
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	scene_tree.current_scene.queue_free()
	scene_tree.root.add_child(game_session)
	scene_tree.current_scene = game_session


static func serialize(game_session: GameSession) -> void:
	var data: Dictionary = {}
	
	data["session_seed"] = game_session._session_seed
	data["story_path"] = game_session._story.resource_path
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
	var selected_story: Story = load(data["story_path"]) as Story
	var grief_stages_stack: GriefStagesStack = GriefStagesStack.new(0)
	grief_stages_stack.deserialize(data["_grief_stages_stack"])
	var memories_stack: MemoriesStack = MemoriesStack.new(0)
	memories_stack.deserialize(data["_memories_stack"])
	var loop_count: int = data["_loop_count"]

	GameSession._create(
		random_seed,
		selected_story,
		grief_stages_stack,
		memories_stack,
		loop_count,
		true
	)
