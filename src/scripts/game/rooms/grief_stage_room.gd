class_name GriefStageRoom
extends Room


signal grief_stage_completed()


@onready var chest_gold: Chest = %ChestGold
@onready var message: Message = %Message

var _closing_memory: Memory
var _collected_memories_counter: int = 0
var _gate: Gate
var _player: Player


func _ready() -> void:
	_setup_chest()
	_setup_message()
	super._ready()


func setup_grief_stage_room(player: Player, closing_memory: Memory, collected_memories_counter: int, gate: Gate, fire_fixtures_states: Array[FireFixtureState]) -> void:
	_player = player
	_closing_memory = closing_memory
	_gate = gate
	_collected_memories_counter = collected_memories_counter
	setup_room(fire_fixtures_states)


func _setup_chest() -> void:
	if !_closing_memory:
		return

	if _closing_memory.is_revealed():
		chest_gold.open_immediately()


func _setup_message() -> void:
	if !_closing_memory:
		return
	
	message.setup_message(_closing_memory.get_description())


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	_player.pause_controls()
	message.show_message()


func _on_message_shown() -> void:
	if _closing_memory:
		_closing_memory.reveal()


func _on_message_hidden() -> void:
	_player.resume_controls()
	grief_stage_completed.emit()


func _on_memory_collected() -> void:
	_collected_memories_counter -= 1
	if _collected_memories_counter == 0:
		_gate.open()


func _on_activator_body_entered(_body: Node3D) -> void:
	_gate.close()
