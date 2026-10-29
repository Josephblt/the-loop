class_name DepressionRoomTest
extends Node3D


@export_group("Memory")
@export_multiline var memory_description: String = "Unknown Memory..."
@export var memory_revealed: bool = false

@export_group("Randomization")
@export var randomize_scene: bool = true
@export var randomization_seed: int = 0

@onready var player: Player = %Player
@onready var depression_room: DepressionRoom = %DepressionRoom
@onready var left_gate: Gate = %LeftGate


func _ready() -> void:
	var memory: Memory = Memory.new(memory_description)
	memory.revealed = memory_revealed

	if randomize_scene:
		SceneRandomizer.randomize_scene(depression_room, randomization_seed)
		SceneRandomizer.randomize_scene(left_gate, randomization_seed)
	depression_room.setup_scene(player, memory)
