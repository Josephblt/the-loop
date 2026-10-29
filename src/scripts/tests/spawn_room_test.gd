class_name SpawnRoomTest
extends Node3D


@export_group("Randomization")
@export var randomize_scene: bool = true
@export var randomization_seed: int = 0

@onready var spawn_room: SpawnRoom = %SpawnRoom
@onready var top_gate: Gate = %TopGate
@onready var bottom_gate: Gate = %BottomGate
@onready var left_gate: Gate = %LeftGate
@onready var right_gate: Gate = %RightGate


func _ready() -> void:
	if randomize_scene:
		SceneRandomizer.randomize_scene(spawn_room, randomization_seed)
		SceneRandomizer.randomize_scene(top_gate, randomization_seed)
		SceneRandomizer.randomize_scene(bottom_gate, randomization_seed)
		SceneRandomizer.randomize_scene(left_gate, randomization_seed)
		SceneRandomizer.randomize_scene(right_gate, randomization_seed)
