class_name IntroPlayer
extends Camera3D


const DEFAULT_MOUSE_SENSITIVITY: float = 0.25

var _look_x: float = 0.0
var _look_y: float = 0.0
var _mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_look_y = rotation_degrees.y


func _input(event):
	if event is InputEventMouseMotion:
		_handle_look(event.relative)


func _handle_look(motion: Vector2) -> void:
	_look_y -= motion.x * _mouse_sensitivity
	_look_x -= motion.y * _mouse_sensitivity
	_look_x = clamp(_look_x, -80, 80) 
	rotation_degrees.y = _look_y 
	rotation_degrees.x = _look_x
