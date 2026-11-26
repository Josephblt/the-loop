class_name Gate
extends Node3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _closed: bool = false


func close(immediately: bool) -> void:
	if _closed:
		return

	if immediately:
		animation_player.play("close_immediately")
	else:
		animation_player.play("close")
		await animation_player.animation_finished
	_closed = true


func open(immediately: bool) -> void:
	if not _closed:
		return

	if immediately:
		animation_player.play("open_immediately")
	else:
		animation_player.play("open")
		await animation_player.animation_finished
	_closed = false
