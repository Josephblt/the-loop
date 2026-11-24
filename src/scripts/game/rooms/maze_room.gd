class_name MazeRoom
extends Node3D


const FLOOR_SCENE: PackedScene = preload("res://game/level/blocks/block_cracked_sm.tscn")
const WALL_BROKEN_LG_SCENE: PackedScene = preload("res://game/level/walls/wall_broken_lg.tscn")
const WALL_BROKEN_MD_SCENE: PackedScene = preload("res://game/level/walls/wall_broken_md.tscn")
const WALL_BROKEN_SM_SCENE: PackedScene = preload("res://game/level/walls/wall_broken_sm.tscn")
const WALL_NORMAL_LG_SCENE: PackedScene = preload("res://game/level/walls/wall_normal_lg.tscn")

@onready var _blocks: Node3D = %Blocks
@onready var _walls: Node3D = %Walls


func setup_room(stage_layout: StageLayout) -> void:
	for index: int in stage_layout.maze_floor_transforms.size():
		var block: Node3D = FLOOR_SCENE.instantiate() as Node3D
		block.name = "Floor%d" % (index + 1)
		block.transform = stage_layout.maze_floor_transforms[index]
		_blocks.add_child(block)

	for index: int in stage_layout.maze_walls.size():
		var wall: MazeWall = stage_layout.maze_walls[index]
		for stack_index: int in wall.stack_count:
			var wall_instance: Node3D = _wall_scene(wall).instantiate() as Node3D
			wall_instance.name = "Wall%d_%d" % [index + 1, stack_index + 1]
			wall_instance.transform = wall.transform
			wall_instance.position.y += float(stack_index) * stage_layout.cell_size
			_walls.add_child(wall_instance)

	SceneRandomizer.randomize_scene(self, stage_layout.session_seed)


func _wall_scene(wall: MazeWall) -> PackedScene:
	if wall.wall_type == MazeWall.WallType.BROKEN:
		match wall.wall_size:
			MazeWall.WallSize.SMALL:
				return WALL_BROKEN_SM_SCENE
			MazeWall.WallSize.MEDIUM:
				return WALL_BROKEN_MD_SCENE
			MazeWall.WallSize.LARGE:
				return WALL_BROKEN_LG_SCENE
	return WALL_NORMAL_LG_SCENE
