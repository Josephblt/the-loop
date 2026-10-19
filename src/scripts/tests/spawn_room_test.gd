extends Node3D


const SPAWN_ROOM_SCENE: PackedScene = preload("res://game/rooms/spawn_room.tscn")

@export var altar_top_left_active: bool = true
@export var altar_top_right_active: bool = true
@export var altar_bottom_left_active: bool = true
@export var altar_bottom_right_active: bool = true
@export var altar_left_bottom_active: bool = true
@export var altar_left_top_active: bool = true
@export var altar_right_bottom_active: bool = true
@export var altar_right_top_active: bool = true
@export var cresset_top_left_active: bool = true
@export var cresset_top_right_active: bool = true
@export var cresset_bottom_left_active: bool = true
@export var cresset_bottom_right_active: bool = true
@export var cresset_left_bottom_active: bool = true
@export var cresset_left_top_active: bool = true
@export var cresset_right_bottom_active: bool = true
@export var cresset_right_top_active: bool = true


@export var randomize_scene: bool = true
@export var randomization_seed: int = 0

@onready var player: Player = %Player

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
	memory.set_fire_fixture_state("Interactables/Cressets/CressetTopLeft/Cresset", cresset_top_left_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetTopRight/Cresset", cresset_top_right_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetBottomLeft/Cresset", cresset_bottom_left_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetBottomRight/Cresset", cresset_bottom_right_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetLeftBottom/Cresset", cresset_left_bottom_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetLeftTop/Cresset", cresset_left_top_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetRightBottom/Cresset", cresset_right_bottom_active)
	memory.set_fire_fixture_state("Interactables/Cressets/CressetRightTop/Cresset", cresset_right_top_active)

	var spawn_room: SpawnRoom = SPAWN_ROOM_SCENE.instantiate() as SpawnRoom
	if randomize_scene:
		SceneRandomizer.randomize_scene(spawn_room, randomization_seed)
	spawn_room.setup_scene(player, memory)
	add_child(spawn_room)
