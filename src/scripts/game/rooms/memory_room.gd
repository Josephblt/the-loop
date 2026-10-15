@tool
class_name MemoryRoom
extends Node3D


@export var editor_seed: int = 0
@export_tool_button("Preview", "RandomNumberGenerator") var preview_action = _preview
@export_tool_button("Reset", "Clear") var clear_action = _reset

@onready var chest: Chest = %Chest
@onready var memory_reveal: MemoryReveal = %MemoryReveal

var _memory: Memory
var _randomizer: RandomNumberGenerator
var _session_seed: int


func _init(random_seed: int = editor_seed, memory: Memory = Memory.new("Unknown Memory...")) -> void:
	_memory = memory
	_session_seed = random_seed


func _ready() -> void:
	if not Engine.is_editor_hint():
		_reset(_session_seed)
		_randomize()
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


func _present_memory() -> void:
	memory_reveal.reveal(_memory._description)


func _on_chest_interaction_triggered() -> void:
	_present_memory()
