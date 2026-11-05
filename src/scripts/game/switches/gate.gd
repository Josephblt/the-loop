class_name Gate
extends Node3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _closed: bool = false


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