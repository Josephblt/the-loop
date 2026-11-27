class_name MazeRoom
extends Node3D


const FLOOR_SCENE: PackedScene = preload("res://game/level/blocks/block_cracked_sm.tscn")
const WALL_BROKEN_MD_SCENE: PackedScene = preload("res://game/level/walls/wall_broken_md.tscn")
const WALL_BROKEN_SM_SCENE: PackedScene = preload("res://game/level/walls/wall_broken_sm.tscn")
const WALL_NORMAL_LG_SCENE: PackedScene = preload("res://game/level/walls/wall_normal_lg.tscn")
const WALL_NORMAL_MD_SCENE: PackedScene = preload("res://game/level/walls/wall_normal_md.tscn")

@onready var _navigation_region: NavigationRegion3D = %NavigationRegion3D
@onready var _blocks: Node3D = %Blocks
@onready var _border_walls: Node3D = %Border
@onready var _medium_walls: Node3D = %Medium
@onready var _small_walls: Node3D = %Small


func setup_room(stage_layout: StageLayout) -> void:
	for index: int in stage_layout.maze_floor_transforms.size():
		var block: Node3D = FLOOR_SCENE.instantiate() as Node3D
		block.name = "Floor%d" % (index + 1)
		block.transform = stage_layout.maze_floor_transforms[index]
		_blocks.add_child(block)

	for index: int in stage_layout.maze_walls.size():
		var wall: MazeWall = stage_layout.maze_walls[index]
		var wall_parent: Node3D = _border_walls
		if wall.wall_size == MazeWall.WallSize.MEDIUM:
			wall_parent = _medium_walls
		elif wall.wall_size == MazeWall.WallSize.SMALL:
			wall_parent = _small_walls

		for stack_index: int in wall.stack_count:
			var wall_instance: Node3D = _wall_scene(wall).instantiate() as Node3D
			wall_instance.name = "Wall%d_%d" % [index + 1, stack_index + 1]
			wall_instance.transform = wall.transform
			wall_instance.position.y += float(stack_index) * stage_layout.cell_size
			wall_parent.add_child(wall_instance)

	SceneRandomizer.randomize_scene(self, stage_layout.session_seed)
	_navigation_region.bake_navigation_mesh(false)


func _wall_scene(wall: MazeWall) -> PackedScene:
	if wall.wall_size == MazeWall.WallSize.SMALL:
		return WALL_BROKEN_SM_SCENE
	if wall.wall_size == MazeWall.WallSize.MEDIUM:
		return WALL_BROKEN_MD_SCENE if wall.wall_type == MazeWall.WallType.BROKEN else WALL_NORMAL_MD_SCENE
	return WALL_NORMAL_LG_SCENE