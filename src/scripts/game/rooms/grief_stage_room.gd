class_name GriefStageRoom
extends Node3D


@onready var chest_gold: Chest = %ChestGold
@onready var memory_reveal: MemoryReveal = %MemoryReveal

var _memory: Memory
var _player: Player


func _ready() -> void:
	_setup_chest()


func setup_scene(player: Player, memory: Memory) -> void:
	_player = player
	_memory = memory


func _setup_chest() -> void:
	if !_memory:
		return
	
	if _memory.revealed:
		chest_gold.open_immediately()


func _on_chest_interaction_triggered() -> void:
	memory_reveal.reveal(_memory.reveal())


func _on_memory_revealed() -> void:
	_player.pause_controls()
	

func _on_memory_dismissed() -> void:
	_player.resume_controls()
