@tool
class_name MemoryRoom
extends Node3D


@onready var chest: Chest = %Chest
@onready var memory_reveal: MemoryReveal = %MemoryReveal

var _memory: Memory
var _player: Player


func _init(player: Player = null, memory: Memory = Memory.new()) -> void:
	_memory = memory
	_player = player


func configure(player: Player, memory: Memory) -> void:
	_player = player
	_memory = memory


func _on_chest_interaction_triggered() -> void:
	memory_reveal.reveal(_memory._description)


func _on_memory_reveal_dismissed() -> void:
	_player.resume_controls()


func _on_memory_reveal_revealed() -> void:
	_player.pause_controls()
