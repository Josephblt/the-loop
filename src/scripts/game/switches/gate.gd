class_name Gate
extends Node3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _closed: bool = false


func is_closed() -> bool:
	return _closed


func close() -> void:
	if _closed:
		return

	animation_player.play("close")
	await animation_player.animation_finished
	_closed = true


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
	animation_player.stop()
	animation_player.play("close_immediately")
	animation_player.advance(0.0)
	animation_player.advance(animation_player.current_animation_length)
	animation_player.stop(true)
	_closed = true


func _open_immediately() -> void:
	animation_player.stop()
	animation_player.play("open_immediately")
	animation_player.advance(0.0)
	animation_player.advance(animation_player.current_animation_length)
	animation_player.stop(true)
	_closed = false
