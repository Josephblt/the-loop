class_name MemoryRoom
extends Room


signal memory_collected()


@onready var chest: Chest = %Chest
@onready var message: Message = %Message

var _memory: Memory
var _player: Player


func _ready() -> void:
	_setup_chest()
	_setup_message()
	super._ready()


func setup_memory_room(player: Player, memory: Memory, fire_fixtures_states: Array[FireFixtureState]) -> void:
	_player = player
	_memory = memory
	setup_room(fire_fixtures_states)


func _setup_chest() -> void:
	if _memory.is_revealed():
		chest.open_immediately()


func _setup_message() -> void:
	message.setup_message(_memory.get_description())


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	_player.pause_controls()
	message.show_message()


func _on_message_shown() -> void:
	_memory.reveal()


func _on_message_hidden() -> void:
	_player.resume_controls()
	memory_collected.emit()
