@tool
class_name MemoryRoom
extends Node3D


@onready var chest: Chest = %Chest
@onready var memory_reveal: MemoryReveal = %MemoryReveal

var _memory: Memory
var _player: Player


func _ready() -> void:
	if _memory.revealed:
		chest.open_immediately()


func setup_scene(player: Player, memory: Memory) -> void:
	_player = player
	_memory = memory


func _on_chest_interaction_triggered() -> void:
	memory_reveal.reveal(_memory.reveal())


func _on_memory_reveal_dismissed() -> void:
	_player.resume_controls()


func _on_memory_reveal_revealed() -> void:
	_player.pause_controls()
