class_name GameSession
extends Node

const SAVE_FILE_PATH = "user://the_loop_save_game.dat"

const GAME_SESSION_SCENE_PATH = "res://scenes/game_session.tscn"
const QUICK_TEST_STAGE: GriefStagesStack.GriefStages = GriefStagesStack.GriefStages.DEPRESSION

var _grief_stages_stack: GriefStagesStack
var _load_existing_loop: bool = false
var _loop_count: int = -1
var _memories_stack: MemoriesStack
var _session_seed: int
var _story: Story

func _ready() -> void:
	if not _load_existing_loop:
		_start_loop()


func _start_loop() -> void:
	_loop_count += 1
	var story_stage: StoryStage = _story.get_stage(_loop_count, QUICK_TEST_STAGE)
	_memories_stack.load_story_stage(story_stage)
	GameSession.serialize(self)


func _end_loop() -> void:
	_grief_stages_stack.pop()
	GameSession.deserialize()


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
	data["grief_stages_stack"] = game_session._grief_stages_stack.serialize()
	data["memories_stack"] = game_session._memories_stack.serialize()
	data["loop_count"] = game_session._loop_count
	
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
	grief_stages_stack.deserialize(data["grief_stages_stack"])
	
	var memories_stack: MemoriesStack = MemoriesStack.new(0)
	memories_stack.deserialize(data["memories_stack"])
	
	var loop_count: int = data["loop_count"]

	GameSession._create(
		random_seed,
		selected_story,
		grief_stages_stack,
		memories_stack,
		loop_count,
		true
	)
