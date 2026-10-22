class_name Gate
extends Node3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer

var active: bool = false


func _ready() -> void:
	_deactivate_immediately()


func is_active() -> bool:
	return active


func activate() -> void:
	animation_player.play("activate")
	await animation_player.animation_finished
	active = true
	

func deactivate() -> void:
	animation_player.play("deactivate")
	await animation_player.animation_finished
	active = false


func _deactivate_immediately() -> void:
	animation_player.play("deactivate")
	animation_player.seek(animation_player.current_animation_length, true)
	animation_player.pause()	
	active = false


func _on_activator_body_exited(_body: Node3D) -> void:
	activate()
