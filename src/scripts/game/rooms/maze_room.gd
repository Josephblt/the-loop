class_name MazeRoom
extends Node3D


const FLOOR_BLOCK_SCENE: PackedScene = preload("res://game/level/blocks/block_cracked_sm.tscn")

var maze: Maze

@onready var _blocks: Node3D = %Blocks


func _ready() -> void:
	assert(maze != null, "MazeRoom requires maze data")
	for cell: Cell in maze.valid_cells():
		var floor_block: Node3D = FLOOR_BLOCK_SCENE.instantiate() as Node3D
		floor_block.name = "Floor%d_%d" % [cell.position.x, cell.position.y]
		floor_block.position = maze.cell_world_position(cell)
		_blocks.add_child(floor_block)
