class_name Gate
extends Node3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _is_inside: bool = false
var _is_outside: bool = false
var _active: bool = false


func _ready() -> void:
	setup(_active)


func is_active() -> bool:
	return _active


func activate() -> void:
	animation_player.play("activate")
	await animation_player.animation_finished
	_active = true
	

func deactivate() -> void:
	animation_player.play("deactivate")
	await animation_player.animation_finished
	_active = false


func setup(active: bool) -> void:
	if active:
		_activate_immediately()
	else:
		_deactivate_immediately()


func _activate_immediately() -> void:
	animation_player.play("activate")
	animation_player.seek(animation_player.current_animation_length, true)
	animation_player.pause()
	_active = true


func _deactivate_immediately() -> void:
	animation_player.play("deactivate")
	animation_player.seek(animation_player.current_animation_length, true)
	animation_player.pause()	
	_active = false


func _on_inside_area_body_entered(_body: Node3D) -> void:
	_is_inside = true


func _on_inside_area_body_exited(_body: Node3D) -> void:
	if _is_outside:
		activate()
		
	_is_inside = false


func _on_outside_area_body_entered(_body: Node3D) -> void:
	_is_outside = true


func _on_outside_area_body_exited(_body: Node3D) -> void:
	_is_outside = false
