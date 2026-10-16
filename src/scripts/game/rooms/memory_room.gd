@tool
class_name MemoryRoom
extends Node3D

@export var editor_seed: int
@export_tool_button("Preview", "RandomNumberGenerator") var preview_action = _preview
@export_tool_button("Reset", "Clear") var clear_action = _reset

@onready var chest: Chest = %Chest
@onready var memory_reveal: MemoryReveal = %MemoryReveal

var _debug: bool
var _memory: Memory
var _player: Player
var _randomizer: RandomNumberGenerator
var _session_seed: int


func _init(random_seed: int = editor_seed, player: Player = null, memory: Memory = Memory.new("Unknown Memory..."), debug: bool = true) -> void:
	_debug = debug
	_memory = memory
	_player = player
	_session_seed = random_seed


func _ready() -> void:
	if _debug:
		_player = DebugHelper.instantiate_player(self, Vector3(0.0, 0.0, 7.4))
		# DebugHelper.instantiate_lights(self)
	
	_reset()
	
	if not Engine.is_editor_hint():
		_randomize()
	

func _randomize():
	var multiplier = _randomizer.randi_range(0, 3)
	rotation.y = deg_to_rad((multiplier * 90) + 90)


func _preview():
	if not Engine.is_editor_hint():
		return

	_reset()
	_randomize()


func _reset() -> void:
	if _debug:
		_session_seed = editor_seed

	rotation.y = 0
	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = _session_seed


func _on_chest_interaction_triggered() -> void:
	memory_reveal.reveal(_memory._description)


func _on_memory_reveal_dismissed() -> void:
	_player.resume_controls()


func _on_memory_reveal_revealed() -> void:
	_player.pause_controls()
