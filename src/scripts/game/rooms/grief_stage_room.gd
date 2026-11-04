class_name GriefStageRoom
extends Room


signal grief_stage_completed()


@onready var chest_gold: Chest = %ChestGold
@onready var message: Message = %Message

var _memory: Memory
var _player: Player
var _gate: Gate


func _ready() -> void:
	_setup_chest()
	_setup_message()
	super._ready()


func setup_grief_stage_room(player: Player, memory: Memory, gate: Gate, fire_fixtures_states: Array[FireFixtureState]) -> void:
	_player = player
	_memory = memory
	_gate = gate
	setup_room(fire_fixtures_states)


func _setup_chest() -> void:
	if !_memory:
		return

	if _memory.is_revealed():
		chest_gold.open_immediately()


func _setup_message() -> void:
	if !_memory:
		return
	
	message.setup_message(_memory.get_description())


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	_player.pause_controls()
	message.show_message()


func _on_message_shown() -> void:
	if _memory:
		_memory.reveal()


func _on_message_hidden() -> void:
	_player.resume_controls()
	grief_stage_completed.emit()


func _on_activator_body_entered(_body: Node3D) -> void:
	_gate.close()
