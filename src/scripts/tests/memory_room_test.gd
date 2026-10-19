extends Node3D


const MEMORY_ROOM_SCENE: PackedScene = preload("res://game/rooms/memory_room.tscn")

@export_multiline var memory_description: String = "Unknown Memory..."
@export var memory_revealed: bool = false

@onready var player: Player = %Player


func _ready() -> void:
	var memory: Memory = Memory.new(memory_description)
	memory.revealed = memory_revealed

	var memory_room: MemoryRoom = MEMORY_ROOM_SCENE.instantiate() as MemoryRoom
	memory_room.configure(player, memory)
	add_child(memory_room)
