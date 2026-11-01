class_name Gate
extends Node3D


const BARRIER_COLLISION_LAYER: int = 1 << 4
const PLAYER_COLLISION_MASK: int = 1 << 1

@onready var barrier: StaticBody3D = $Barrier
@onready var animation_player: AnimationPlayer = %AnimationPlayer

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
	animation_player.play("close")
	animation_player.advance(0.0)
	animation_player.advance(animation_player.current_animation_length)
	animation_player.pause()
	barrier.collision_layer = BARRIER_COLLISION_LAYER
	barrier.collision_mask = PLAYER_COLLISION_MASK
	_closed = true


func _open_immediately() -> void:
	animation_player.stop()
	animation_player.play("open")
	animation_player.advance(0.0)
	animation_player.advance(animation_player.current_animation_length)
	animation_player.pause()
	barrier.collision_layer = 0
	barrier.collision_mask = 0
	_closed = false
