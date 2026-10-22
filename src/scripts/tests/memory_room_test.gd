class_name MemoryRoomTest
extends Node3D


@export_group("Memory")
@export_multiline var memory_description: String = "Unknown Memory..."
@export var memory_revealed: bool = false

@export_group("Altars")
@export var altar_left_active: bool = true
@export var altar_right_active: bool = true

@export_group("Randomization")
@export var randomize_scene: bool = true
@export var randomization_seed: int = 0

@onready var player: Player = %Player
@onready var memory_room: MemoryRoom = %MemoryRoom


func _ready() -> void:
	var memory: Memory = Memory.new(memory_description)
	memory.revealed = memory_revealed
	memory.set_fire_fixture_state("Interactables/Altars/AltarLeft", altar_left_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarRight", altar_right_active)

	if randomize_scene:
		SceneRandomizer.randomize_scene(memory_room, randomization_seed)
	memory_room.setup_scene(player, memory)
