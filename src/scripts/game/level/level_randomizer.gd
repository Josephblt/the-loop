@tool
class_name LevelRandomizer
extends StaticBody3D


@export_group("Randomization")
@export var original_position: Vector3 = Vector3.ZERO
@export var original_rotation: Vector3 = Vector3.ZERO
@export var editor_seed: int = 0

@export var x_position: float = 0.01
@export var y_position: float = 0.01
@export var z_position: float = 0.01

@export var x_rotation: float = 0.1
@export var y_rotation: float = 0.1
@export var z_rotation: float = 0.1

@export_tool_button("Randomize", "RandomNumberGenerator") var preview_action = _randomize
@export_tool_button("Reset", "Clear") var clear_action = _reset

var _randomizer: RandomNumberGenerator


func _ready() -> void:
	if Engine.is_editor_hint():
		_reset()
	else:
		_randomize()
		

func _randomize_position() -> void:
	var x = _randomizer.randf_range(-x_position, x_position)
	var y = _randomizer.randf_range(-y_position, y_position)
	var z = _randomizer.randf_range(-z_position, z_position)
	
	%MeshInstance3D.position += Vector3(x, y, z)


func _randomize_rotation() -> void:
	var x = _randomizer.randf_range(-x_rotation, x_rotation)
	var y = _randomizer.randf_range(-y_rotation, y_rotation)
	var z = _randomizer.randf_range(-z_rotation, z_rotation)

	%MeshInstance3D.rotation_degrees += Vector3(x, y, z)


func _randomize_inversion() -> void:
	var invert = _randomizer.randi_range(0, 1) == 1
	if invert:
		%MeshInstance3D.rotation_degrees.y += 180


func _randomize():
	_randomize_position()
	_randomize_rotation()
	_randomize_inversion()


func _reset() -> void:
	%MeshInstance3D.position = original_position
	%MeshInstance3D.rotation_degrees = original_rotation
