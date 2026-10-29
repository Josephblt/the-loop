class_name DenialRoomTest
extends Node3D


@export_group("Memory")
@export_multiline var memory_description: String = "Unknown Memory..."
@export var memory_revealed: bool = false

@export_group("Randomization")
@export var randomize_scene: bool = true
@export var randomization_seed: int = 0

@onready var player: Player = %Player
@onready var denial_room: DenialRoom = %DenialRoom
@onready var bottom_gate: Gate = %BottomGate


func _ready() -> void:
	var memory: Memory = Memory.new(memory_description)
	memory.revealed = memory_revealed

	if randomize_scene:
		SceneRandomizer.randomize_scene(denial_room, randomization_seed)
		SceneRandomizer.randomize_scene(bottom_gate, randomization_seed)
	denial_room.setup_scene(player, memory)
