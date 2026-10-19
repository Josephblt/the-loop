extends Node3D


const MEMORY_ROOM_SCENE: PackedScene = preload("res://game/rooms/memory_room.tscn")
const RANDOMIZATION_CATALOG: RandomizationCatalog = preload("res://addons/level_randomization/config/randomization_catalog.tres")

@export_multiline var memory_description: String = "Unknown Memory..."
@export var memory_revealed: bool = false
@export var randomization_seed: int = 0

@onready var player: Player = %Player


func _ready() -> void:
	var memory: Memory = Memory.new(memory_description)
	memory.revealed = memory_revealed

	var memory_room: MemoryRoom = MEMORY_ROOM_SCENE.instantiate() as MemoryRoom
	_randomize_scene(memory_room)
	memory_room.setup_scene(player, memory)
	add_child(memory_room)


func _randomize_scene(scene_root: Node3D) -> void:
	var nodes: Array[Node] = scene_root.find_children("*", "Node3D", true, false)
	for node: Node in nodes:
		_randomize_scene_instance(scene_root, node as Node3D)


func _randomize_scene_instance(scene_root: Node3D, scene_instance: Node3D) -> void:
	var binding: SceneRandomizationBinding = RANDOMIZATION_CATALOG.find_binding(scene_instance)
	if !binding:
		return

	for target_binding: TargetRandomizationBinding in binding.targets:
		var target: Node3D = target_binding.get_target(scene_instance)
		if !target or !target_binding.profile:
			continue

		var identity: String = _get_identity(scene_root, scene_instance, binding, target_binding)
		var state: TransformRandomizationState = TransformRandomizer.generate(
			target.position, target.rotation, target_binding.profile, randomization_seed, identity
		)
		target.position = state.position
		target.rotation = state.rotation


func _get_identity(scene_root: Node3D, scene_instance: Node3D, binding: SceneRandomizationBinding, target_binding: TargetRandomizationBinding) -> String:
	var instance_path: String = "/root/%s/%s" % [scene_root.name, scene_root.get_path_to(scene_instance)]
	return "%s:%s:%s" % [binding.source_scene.resource_path, instance_path, target_binding.target_path]
