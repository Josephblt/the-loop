extends Node3D


const MEMORY_ROOM_SCENE: PackedScene = preload("res://game/rooms/memory_room.tscn")

@export_multiline var memory_description: String = "Unknown Memory..."
@export var memory_revealed: bool = false
@export var randomize_scene: bool = true
@export var randomization_seed: int = 0


@onready var player: Player = %Player


func _ready() -> void:
	var memory: Memory = Memory.new(memory_description)
	memory.revealed = memory_revealed

	var memory_room: MemoryRoom = MEMORY_ROOM_SCENE.instantiate() as MemoryRoom
	if randomize_scene:
		SceneRandomizer.randomize_scene(memory_room, randomization_seed)
	memory_room.setup_scene(player, memory)
	add_child(memory_room)
