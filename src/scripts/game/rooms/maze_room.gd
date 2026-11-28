class_name MazeRoom
extends Node3D


const FLOOR_SCENE: PackedScene = preload("res://game/level/blocks/block_cracked_sm.tscn")
const WALL_BROKEN_MD_SCENE: PackedScene = preload("res://game/level/walls/wall_broken_md.tscn")
const WALL_BROKEN_SM_SCENE: PackedScene = preload("res://game/level/walls/wall_broken_sm.tscn")
const WALL_NORMAL_LG_SCENE: PackedScene = preload("res://game/level/walls/wall_normal_lg.tscn")
const WALL_NORMAL_MD_SCENE: PackedScene = preload("res://game/level/walls/wall_normal_md.tscn")
const MAZE_DENIAL_SCENE: PackedScene = preload("res://game/actors/enemy/enemy_behaviour/maze/maze_denial.tscn")

@onready var _blocks: Node3D = %Blocks
@onready var _border_walls: Node3D = %Border
@onready var _medium_walls: Node3D = %Medium
@onready var _small_walls: Node3D = %Small
@onready var _enemy: Enemy = %Enemy


func setup_room(stage_layout: StageLayout, player: Player, grief_stage: GriefStagesStack.GriefStages) -> void:
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
			wall_instance.position.y += float(stack_index) * stage_layout.CELL_SIZE
			wall_parent.add_child(wall_instance)

	_enemy.position = stage_layout.maze_enemy_transform.origin
	
	if grief_stage == GriefStagesStack.GriefStages.DENIAL:
		var graph: MazePathGraph = MazePathGraph.new(stage_layout)
		var behaviour: MazeDenial = MAZE_DENIAL_SCENE.instantiate() as MazeDenial
		_enemy.add_child(behaviour)
		_enemy.ai_behaviour = behaviour
		behaviour.setup_maze(_enemy, player, graph)
		behaviour.set_physics_process(false)

	SceneRandomizer.randomize_scene(self, stage_layout.session_seed)


func enable_enemy_ai() -> void:
	if _enemy.ai_behaviour == null:
		return
	_enemy.ai_behaviour.set_physics_process(true)


func get_enemy_behaviour() -> EnemyBehaviour:
	return _enemy.ai_behaviour


func _wall_scene(wall: MazeWall) -> PackedScene:
	if wall.wall_size == MazeWall.WallSize.SMALL:
		return WALL_BROKEN_SM_SCENE
	if wall.wall_size == MazeWall.WallSize.MEDIUM:
		return WALL_BROKEN_MD_SCENE if wall.wall_type == MazeWall.WallType.BROKEN else WALL_NORMAL_MD_SCENE
	return WALL_NORMAL_LG_SCENE
