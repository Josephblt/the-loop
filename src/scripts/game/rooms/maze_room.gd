class_name MazeRoom
extends Node3D


const FLOOR_BLOCK_SCENE: PackedScene = preload("res://game/level/blocks/block_cracked_sm.tscn")
const BORDER_WALL_SCENE: PackedScene = preload("res://game/level/walls/wall_normal_lg.tscn")
const BORDER_WALL_STACK_HEIGHT: float = 5.6

var maze: Maze
var randomization_seed: int

@onready var _blocks: Node3D = %Blocks
@onready var _walls: Node3D = %Walls


func _ready() -> void:
	assert(maze != null, "MazeRoom requires maze data")
	for cell: Cell in maze.valid_cells():
		var floor_block: Node3D = FLOOR_BLOCK_SCENE.instantiate() as Node3D
		floor_block.name = "Floor%d_%d" % [cell.position.x, cell.position.y]
		floor_block.position = maze.cell_world_position(cell)
		_blocks.add_child(floor_block)

	for wall: Wall in maze.walls:
		if wall.wall_type == Wall.WallType.BORDER:
			_spawn_border_wall(wall)

	SceneRandomizer.randomize_scene(self, randomization_seed)


func _spawn_border_wall(wall: Wall) -> void:
	var wall_transform: Transform3D = maze.wall_world_transform(wall)
	var axis_name: String = "Horizontal"
	if wall.axis == Wall.WallAxis.VERTICAL:
		axis_name = "Vertical"
	var bottom_wall: Node3D = BORDER_WALL_SCENE.instantiate() as Node3D
	bottom_wall.name = "%sBorderWall%d_%dBottom" % [axis_name, wall.position.x, wall.position.y]
	bottom_wall.transform = wall_transform
	_walls.add_child(bottom_wall)

	var top_wall: Node3D = BORDER_WALL_SCENE.instantiate() as Node3D
	top_wall.name = "%sBorderWall%d_%dTop" % [axis_name, wall.position.x, wall.position.y]
	top_wall.transform = wall_transform
	top_wall.position.y += BORDER_WALL_STACK_HEIGHT
	_walls.add_child(top_wall)
