class_name MemoryRoom
extends Room


@onready var chest: Chest = %Chest
@onready var memory_reveal: MemoryReveal = %MemoryReveal

var _memory: Memory
var _player: Player


func get_room_id() -> String:
	return name.to_snake_case()


func _ready() -> void:
	_setup_chest()


func setup_scene(player: Player, memory: Memory) -> void:
	_player = player
	_memory = memory


func _setup_chest() -> void:
	if !_memory:
		return
	
	if _memory.revealed:
		chest.open_immediately()


func _on_chest_interaction_triggered() -> void:
	memory_reveal.reveal(_memory.reveal())


func _on_memory_revealed() -> void:
	_player.pause_controls()


func _on_memory_dismissed() -> void:
	_player.resume_controls()
