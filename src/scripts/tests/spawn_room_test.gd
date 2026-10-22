class_name SpawnRoomTest
extends Node3D


@export_group("Altars")
@export var altar_top_left_active: bool = true
@export var altar_top_right_active: bool = true
@export var altar_bottom_left_active: bool = true
@export var altar_bottom_right_active: bool = true
@export var altar_left_bottom_active: bool = true
@export var altar_left_top_active: bool = true
@export var altar_right_bottom_active: bool = true
@export var altar_right_top_active: bool = true

@export_group("Cressets")
@export var cresset_top_left_active: bool = true
@export var cresset_top_right_active: bool = true
@export var cresset_bottom_left_active: bool = true
@export var cresset_bottom_right_active: bool = true
@export var cresset_left_bottom_active: bool = true
@export var cresset_left_top_active: bool = true
@export var cresset_right_bottom_active: bool = true
@export var cresset_right_top_active: bool = true

@export_group("Randomization")
@export var randomize_scene: bool = true
@export var randomization_seed: int = 0

@onready var player: Player = %Player
@onready var spawn_room: SpawnRoom = %SpawnRoom


func _ready() -> void:
	var memory: Memory = Memory.new("Spawn Room Memory")
	memory.set_fire_fixture_state("Interactables/Altars/AltarTopLeft", altar_top_left_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarTopRight", altar_top_right_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarBottomLeft", altar_bottom_left_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarBottomRight", altar_bottom_right_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarLeftBottom", altar_left_bottom_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarLeftTop", altar_left_top_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarRightBottom", altar_right_bottom_active)
	memory.set_fire_fixture_state("Interactables/Altars/AltarRightTop", altar_right_top_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetTopLeft", cresset_top_left_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetTopRight", cresset_top_right_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetBottomLeft", cresset_bottom_left_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetBottomRight", cresset_bottom_right_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetLeftBottom", cresset_left_bottom_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetLeftTop", cresset_left_top_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetRightBottom", cresset_right_bottom_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetRightTop", cresset_right_top_active)

	if randomize_scene:
		SceneRandomizer.randomize_scene(spawn_room, randomization_seed)
	spawn_room.setup_scene(player, memory)
