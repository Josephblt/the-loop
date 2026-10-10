@tool
extends Node

const BLOCK_SCENES: Array[PackedScene] = [
	preload("res://game/level/blocks/block_cracked_sm.tscn"),
]

const BORDER_BOTTOM_WALL_SCENES: Array[PackedScene] = [
	preload("res://game/level/walls/wall_normal_lg.tscn"),
	# preload("res://game/level/walls/wall_normal_md.tscn"),
	# preload("res://game/level/walls/wall_normal_sm.tscn"),
	# preload("res://game/level/walls/wall_broken_lg.tscn"),
	# preload("res://game/level/walls/wall_broken_md.tscn"),
	# preload("res://game/level/walls/wall_broken_sm.tscn"),
]

const BORDER_TOP_WALL_SCENES: Array[PackedScene] = [
	preload("res://game/level/walls/wall_normal_lg.tscn"),
	# preload("res://game/level/walls/wall_normal_md.tscn"),
	# preload("res://game/level/walls/wall_normal_sm.tscn"),
	# preload("res://game/level/walls/wall_broken_lg.tscn"),
	# preload("res://game/level/walls/wall_broken_md.tscn"),
	# preload("res://game/level/walls/wall_broken_sm.tscn"),
]

const MAZE_WALL_SCENES: Array[PackedScene] = [
	preload("res://game/level/walls/wall_normal_lg.tscn"),
	# preload("res://game/level/walls/wall_normal_md.tscn"),
	# preload("res://game/level/walls/wall_normal_sm.tscn"),
	# preload("res://game/level/walls/wall_broken_lg.tscn"),
	# preload("res://game/level/walls/wall_broken_md.tscn"),
	# preload("res://game/level/walls/wall_broken_sm.tscn"),
]

const GATE_WALL_SCENE: PackedScene = preload("res://game/level/walls/gate.tscn")

const CELL_SIZE: float = 5.6

@export var editor_grid_size: int = 25
@export var editor_spawn_size: int = 7
@export var editor_seed: int = 0
@export var editor_grief_stage: GriefStagesStack.GriefStages = GriefStagesStack.GriefStages.DENIAL
@export_tool_button("Preview - ", "RandomNumberGenerator") var preview_action = _preview
@export_tool_button("Clear", "Clear") var clear_action = _clear

@onready var _blocks: Node3D = %Blocks
@onready var _gates: Node3D = %Gates
@onready var _walls: Node3D = %Walls

var _gameSession: GameSession
var _maze: Maze
var _randomizer: RandomNumberGenerator


func _ready() -> void:
	_randomizer = RandomNumberGenerator.new()
	
	if Engine.is_editor_hint():
		_clear()
	else:
		_gameSession = GameManager.current_game_session
		if _gameSession:
			_randomizer.seed = _gameSession.session_seed
			_maze = Maze.new(
				_gameSession._current_grief_stage, 
				_gameSession.session_seed, 
				_gameSession.grid_size, 
				_gameSession.spawn_size
			)
		else:
			_randomizer.seed = editor_seed
			_maze = Maze.new(
				editor_grief_stage, 
				editor_seed, 
				editor_grid_size, 
				editor_spawn_size
			)
		
		_spawn()


func _spawn_block(x: int, y: int) -> void:
	var offset: float = ((_maze.grid_size / 2.0) * CELL_SIZE) - (CELL_SIZE / 2.0)

	var block_scene: PackedScene = BLOCK_SCENES[_randomizer.randi_range(0, BLOCK_SCENES.size() - 1)]
	var block_instance: Node3D = block_scene.instantiate()
	block_instance.name = "Block"
	block_instance.position = Vector3((x * CELL_SIZE) - offset, 0, (y * CELL_SIZE) - offset)
	block_instance._preview()
	_blocks.add_child(block_instance)


func _spawn_border_wall(x: int, y: int, wall_direction: Wall.WallDirection) -> void:
	var offset: float = ((_maze.grid_size / 2.0) * CELL_SIZE) - (CELL_SIZE / 2.0)

	var bottom_wall_scene: PackedScene = BORDER_BOTTOM_WALL_SCENES[_randomizer.randi_range(0, BORDER_BOTTOM_WALL_SCENES.size() - 1)]
	var bottom_wall_instance: Node3D = bottom_wall_scene.instantiate()
	bottom_wall_instance.position = Vector3((x * CELL_SIZE) - offset, 0, (y * CELL_SIZE) - offset)
	bottom_wall_instance.name = "BorderWall"
		
	var top_wall_scene: PackedScene = BORDER_TOP_WALL_SCENES[_randomizer.randi_range(0, BORDER_TOP_WALL_SCENES.size() - 1)]
	var top_wall_instance: Node3D = top_wall_scene.instantiate()
	top_wall_instance.position = Vector3((x * CELL_SIZE) - offset, 6.0, (y * CELL_SIZE) - offset)
	top_wall_instance.name = "BorderWall"
	
	match wall_direction:
		Wall.WallDirection.NORTH:
			bottom_wall_instance.rotation_degrees = Vector3(0, 0, 0)
			top_wall_instance.rotation_degrees = Vector3(0, 0, 0)
		Wall.WallDirection.SOUTH:
			bottom_wall_instance.rotation_degrees = Vector3(0, 180, 0)
			top_wall_instance.rotation_degrees = Vector3(0, 180, 0)
		Wall.WallDirection.EAST:
			bottom_wall_instance.rotation_degrees = Vector3(0, -90, 0)
			top_wall_instance.rotation_degrees = Vector3(0, -90, 0)
		Wall.WallDirection.WEST:
			bottom_wall_instance.rotation_degrees = Vector3(0, 90, 0)
			top_wall_instance.rotation_degrees = Vector3(0, 90, 0)
	
	_walls.add_child(bottom_wall_instance)
	_walls.add_child(top_wall_instance)


func _spawn_gate_wall(x: int, y: int, wall_direction: Wall.WallDirection) -> void:
	var offset: float = ((_maze.grid_size / 2.0) * CELL_SIZE) - (CELL_SIZE / 2.0)

	var gate_scene: PackedScene = GATE_WALL_SCENE
	var gate_instance: Node3D = gate_scene.instantiate()	
	gate_instance.position = Vector3((x * CELL_SIZE) - offset, 0, (y * CELL_SIZE) - offset)
	gate_instance.name = "BottomGateWall"

	var wall_scene: PackedScene = BORDER_TOP_WALL_SCENES[_randomizer.randi_range(0, BORDER_TOP_WALL_SCENES.size() - 1)]
	var top_wall_instance: Node3D = wall_scene.instantiate()
	top_wall_instance.position = Vector3((x * CELL_SIZE) - offset, 6.0, (y * CELL_SIZE) - offset)
	top_wall_instance.name = "TopGateWall"

	match wall_direction:
		Wall.WallDirection.NORTH:
			gate_instance.rotation_degrees = Vector3(0, 0, 0)
			top_wall_instance.rotation_degrees = Vector3(0, 0, 0)
		Wall.WallDirection.SOUTH:
			gate_instance.rotation_degrees = Vector3(0, 180, 0)
			top_wall_instance.rotation_degrees = Vector3(0, 180, 0)
		Wall.WallDirection.EAST:
			gate_instance.rotation_degrees = Vector3(0, -90, 0)
			top_wall_instance.rotation_degrees = Vector3(0, -90, 0)
		Wall.WallDirection.WEST:
			gate_instance.rotation_degrees = Vector3(0, 90, 0)
			top_wall_instance.rotation_degrees = Vector3(0, 90, 0)
	
	_gates.add_child(gate_instance)
	_walls.add_child(top_wall_instance)


func _spawn_maze_wall(x: int, y: int, wall_direction: Wall.WallDirection) -> void:
	var offset: float = ((_maze.grid_size / 2.0) * CELL_SIZE) - (CELL_SIZE / 2.0)

	var wall_scene: PackedScene = MAZE_WALL_SCENES[_randomizer.randi_range(0, MAZE_WALL_SCENES.size() - 1)]
	var wall_instance: WallRandomizer = wall_scene.instantiate()
	wall_instance.position += Vector3((x * CELL_SIZE) - offset, 0, (y * CELL_SIZE) - offset)
	wall_instance.name = "MazeWall"

	match wall_direction:
		Wall.WallDirection.NORTH:
			wall_instance.rotation_degrees = Vector3(0, 0, 0)
		Wall.WallDirection.SOUTH:
			wall_instance.rotation_degrees = Vector3(0, 180, 0)
		Wall.WallDirection.EAST:
			wall_instance.rotation_degrees = Vector3(0, -90, 0)
		Wall.WallDirection.WEST:
			wall_instance.rotation_degrees = Vector3(0, 90, 0)
	
	_walls.add_child(wall_instance)


func _spawn_walls(cell: Cell, x: int, y: int) -> void:
	if y == 0 or (y == _maze.spawn_end + 1 and x >= _maze.spawn_start and x <= _maze.spawn_end):
		_spawn_wall(cell, x, y, Wall.WallDirection.NORTH)
	
	if x == 0 or (x == _maze.spawn_end + 1 and y >= _maze.spawn_start and y <= _maze.spawn_end):
		_spawn_wall(cell, x, y, Wall.WallDirection.WEST)
	
	_spawn_wall(cell, x, y, Wall.WallDirection.SOUTH)
	_spawn_wall(cell, x, y, Wall.WallDirection.EAST)


func _spawn_wall(cell: Cell, x: int, y: int, wall_direction: Wall.WallDirection) -> void:
	var wall: Wall = cell.walls[wall_direction]
	if !wall:
		return

	match wall.type:
		Wall.WallType.BORDER_WALL:
			_spawn_border_wall(x, y, wall.direction)
		Wall.WallType.GATE_WALL:
			_spawn_gate_wall(x, y, wall.direction)
		Wall.WallType.MAZE_WALL:
			_spawn_maze_wall(x, y, wall.direction)
		_:
			return
	

func _spawn() -> void:
	for x in _maze.grid_size:
		for y in _maze.grid_size:
			var cell: Cell = _maze.grid[x][y]
			if cell:
				if cell.cell_type != Cell.CellType.MEMORY:
					_spawn_block(x, y)
				_spawn_walls(cell, x, y)
		

func _clear() -> void:
	if Engine.is_editor_hint():
		_maze = null
		for block in _blocks.get_children():
			block.queue_free()
		for wall in _walls.get_children():
			wall.queue_free()
		for gate in _gates.get_children():
			gate.queue_free()


func _preview() -> void: 
	if !Engine.is_editor_hint():
		return

	_clear()
	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = editor_seed
	_maze = Maze.new(editor_grief_stage, editor_seed, editor_grid_size, editor_spawn_size)
	_spawn()
