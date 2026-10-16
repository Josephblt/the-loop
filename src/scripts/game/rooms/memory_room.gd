@tool
class_name MemoryRoom
extends Node3D

@export var editor_seed: int = 0
@export var editor_player: PackedScene
@export_tool_button("Preview", "RandomNumberGenerator") var preview_action = _preview
@export_tool_button("Reset", "Clear") var clear_action = _reset

@onready var chest: Chest = %Chest
@onready var memory_reveal: MemoryReveal = %MemoryReveal

var _player: Player
var _memory: Memory
var _randomizer: RandomNumberGenerator
var _session_seed: int


func _init(random_seed: int = editor_seed, player: Player = null, memory: Memory = Memory.new("Unknown Memory...")) -> void:
	_player = player
	_memory = memory
	_session_seed = random_seed


func _ready() -> void:
	if not Engine.is_editor_hint():
		_reset(_session_seed)
		_randomize()
	else:
		_reset(editor_seed)
	
	if !_player:
		_instantiate_player()
	

func _instantiate_player() -> void:
	_player = editor_player.instantiate() as Player
	_player.position = Vector3(0.0, 0.0, 7.4)
	add_child(_player)
	

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


func _on_chest_interaction_triggered() -> void:
	memory_reveal.reveal(_memory._description)


func _on_memory_reveal_dismissed() -> void:
	_player.resume_controls()


func _on_memory_reveal_revealed() -> void:
	_player.pause_controls()
