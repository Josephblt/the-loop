@tool
extends Node


const FLOOR_SCENES: Array[PackedScene] = [
	preload("res://game/level/blocks/block_cracked_sm.tscn"),
]

const WALL_SCENES: Array[PackedScene] = [
	preload("res://game/level/walls/wall_broken_lg.tscn"),
	preload("res://game/level/walls/wall_normal_lg.tscn"),
]

const ENTRY_WALL_SCENES: Array[PackedScene] = [
	preload("res://game/level/walls/entry_left.tscn"),
	preload("res://game/level/walls/entry_right.tscn")
]

@export var editor_grid_size: int = 25
@export var editor_spawn_size: int = 7
@export var editor_seed: int = 0
@export var editor_direction: Wall.WallDirection = Wall.WallDirection.NORTH
@export_tool_button("Preview", "RandomNumberGenerator") var preview_action = _preview
@export_tool_button("Clear", "Clear") var clear_action = _clear


var _randomizer: RandomNumberGenerator
var _gameSession: GameSession


func _ready():
	_randomizer = RandomNumberGenerator.new()

	if Engine.is_editor_hint():
		_clear()
	else:
		_gameSession = GameManager.current_game_session
		if _gameSession:
			_randomizer.seed = _gameSession.session_seed
			
		else:
			_randomizer.seed = editor_seed			

		_build()
	

func _spawn_north_wall():
	pass


func _spawn_south_wall():
	pass


func _spawn_west_wall():
	pass


func _spawn_east_wall():
	pass


func _spawn_entry_walls():
	pass


func _build():
	_spawn_north_wall()
	_spawn_west_wall()
	_spawn_east_wall()
	_spawn_entry_walls()


func _clear():
	if Engine.is_editor_hint():
		var walls = %Walls
		for wall in walls.get_children():
			wall.queue_free()


func _preview():
	if !Engine.is_editor_hint():
		return

	print("Previewing memory room with seed: ", _randomizer.seed)

	_clear()
	_build()
