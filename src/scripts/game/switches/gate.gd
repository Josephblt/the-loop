class_name Gate
extends Node3D


signal closed


@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _is_inside: bool = false
var _is_outside: bool = false
var _closed: bool = false


func _ready() -> void:
	setup(_closed)


func is_closed() -> bool:
	return _closed


func close() -> void:
	if _closed:
		return

	animation_player.play("close")
	await animation_player.animation_finished
	_closed = true
	closed.emit()


func open() -> void:
	animation_player.play("open")
	await animation_player.animation_finished
	_closed = false


func setup(closed_state: bool) -> void:
	if closed_state:
		_close_immediately()
	else:
		_open_immediately()


func _close_immediately() -> void:
	animation_player.play("close")
	animation_player.seek(animation_player.current_animation_length, true)
	animation_player.pause()
	_closed = true


func _open_immediately() -> void:
	animation_player.play("open")
	animation_player.seek(animation_player.current_animation_length, true)
	animation_player.pause()
	_closed = false


func _on_inside_area_body_entered(_body: Node3D) -> void:
	_is_inside = true


func _on_inside_area_body_exited(_body: Node3D) -> void:
	if _is_outside:
		close()
		
	_is_inside = false


func _on_outside_area_body_entered(_body: Node3D) -> void:
	_is_outside = true


func _on_outside_area_body_exited(_body: Node3D) -> void:
	_is_outside = false
