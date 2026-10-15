@tool
class_name MemoryRoom
extends Node3D

@export var editor_seed: int = 0
@export_tool_button("Preview", "RandomNumberGenerator") var preview_action = _preview
@export_tool_button("Reset", "Clear") var clear_action = _reset

var _memory: Memory
var _randomizer: RandomNumberGenerator
var _session_seed: int

@onready var chest: Chest = %Chest
@onready var memory_presentation: MemoryPresentation = %MemoryPresentation


func _init(random_seed: int = editor_seed, memory: Memory = null) -> void:
	_memory = memory
	_session_seed = random_seed


func _ready() -> void:
	if not Engine.is_editor_hint():
		_reset(_session_seed)
		_randomize()
		_connect_memory_interaction()
	else:
		_reset(editor_seed)
	

func _randomize():
	rotation.y = deg_to_rad(_randomizer.randi_range(0, 3) * 90)


func _preview():
	if not Engine.is_editor_hint():
		return

	_reset(editor_seed)
	_randomize()


func _reset(random_seed: int = editor_seed) -> void:
	rotation.y = 0
	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = random_seed

	if not Engine.is_editor_hint():
		return


func _connect_memory_interaction() -> void:
	chest.interaction_triggered.connect(_present_memory)


func _present_memory() -> void:
	var memory_text: String = "Unknown Memory..."
	if _memory:
		memory_text = _memory.description

	memory_presentation.present(memory_text)
