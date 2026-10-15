@tool
class_name LevelRandomizer
extends StaticBody3D

@export var editor_seed: int = 0
@export_tool_button("Preview", "RandomNumberGenerator") var preview_action = _preview
@export_tool_button("Reset", "Clear") var clear_action = _reset


const X_POSITION: float = 0.01
const Y_POSITION: float = 0.01
const Z_POSITION: float = 0.01

const X_ROTATION: float = 0.1
const Y_ROTATION: float = 0.1
const Z_ROTATION: float = 0.1

var _inverted: bool
var _mesh_random_position: Vector3
var _mesh_random_rotation: Vector3
var _randomizer: RandomNumberGenerator
var _session_seed: int


func _init(random_seed: int = editor_seed) -> void:
	_session_seed = random_seed
	_mesh_random_position = Vector3.ZERO
	_mesh_random_rotation = Vector3.ZERO
	_inverted = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		_reset(_session_seed)
		_randomize()
	else:
		_reset(editor_seed)
		

func _randomize_position() -> void:
	_mesh_random_position = Vector3(
		_randomizer.randf_range(-X_POSITION, X_POSITION),
		_randomizer.randf_range(-Y_POSITION, Y_POSITION),
		_randomizer.randf_range(-Z_POSITION, Z_POSITION)
	)
	%MeshInstance3D.position += _mesh_random_position


func _randomize_rotation() -> void:
	_mesh_random_rotation = Vector3(
		_randomizer.randf_range(-X_ROTATION, X_ROTATION),
		_randomizer.randf_range(-Y_ROTATION, Y_ROTATION),
		_randomizer.randf_range(-Z_ROTATION, Z_ROTATION)
	)
	
	%MeshInstance3D.rotation_degrees.x += _mesh_random_rotation.x
	%MeshInstance3D.rotation_degrees.y += _mesh_random_rotation.y
	%MeshInstance3D.rotation_degrees.z += _mesh_random_rotation.z


func _randomize_inversion() -> void:
	_inverted = _randomizer.randi_range(0, 1) == 1
	
	if _inverted:
		%MeshInstance3D.rotation_degrees.y += 180


func _randomize():
	_randomize_position()
	_randomize_rotation()
	_randomize_inversion()


func _reset(random_seed: int = editor_seed) -> void:
	%MeshInstance3D.position -= _mesh_random_position
	%MeshInstance3D.rotation_degrees -= _mesh_random_rotation
	if _inverted:
		%MeshInstance3D.rotation_degrees.y -= 180

	_mesh_random_position = Vector3.ZERO
	_mesh_random_rotation = Vector3.ZERO
	_inverted = false

	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = random_seed

	if not Engine.is_editor_hint():
		return

	ClearHelper.pressClearButton()


func _preview():
	if not Engine.is_editor_hint():
		return

	_reset(editor_seed)
	_randomize()
	ClearHelper.pressClearButton()
