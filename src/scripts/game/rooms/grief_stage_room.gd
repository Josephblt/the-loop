class_name GriefStageRoom
extends Room


signal grief_stage_completed()


@onready var chest_gold: Chest = %ChestGold
@onready var message: Message = %Message

var _memory: Memory
var _player: Player


func _ready() -> void:
	_setup_chest()
	_setup_message()


func setup_scene(player: Player, memory: Memory) -> void:
	_player = player
	_memory = memory


func _setup_chest() -> void:
	if _memory.is_revealed():
		chest_gold.open_immediately()


func _setup_message() -> void:
	message.setup_message(_memory.get_description())


func _on_chest_interaction_triggered() -> void:
	_player.pause_controls()	


func _on_message_shown() -> void:
	_memory.reveal()


func _on_message_hidden() -> void:
	_player.resume_controls()
	grief_stage_completed.emit()