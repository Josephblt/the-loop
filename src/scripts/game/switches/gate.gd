class_name Gate
extends Node3D


@export var closed: bool = false

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	if closed:
		animation_player.play("close_immediately")
	else:
		animation_player.play("open_immediately")


func close(immediately: bool) -> void:
	if closed:
		return

	if immediately:
		animation_player.play("close_immediately")
	else:
		animation_player.play("close")
		await animation_player.animation_finished
	closed = true


func open(immediately: bool) -> void:
	if not closed:
		return

	if immediately:
		animation_player.play("open_immediately")
	else:
		animation_player.play("open")
		await animation_player.animation_finished
	closed = false
