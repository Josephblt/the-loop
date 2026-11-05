class_name Reticle
extends Control

const CENTER_DOT_RADIUS: float = 2.0
const OUTER_RING_RADIUS: float = 9.0
const OUTER_RING_WIDTH: float = 2.0
const SHADOW_WIDTH: float = 4.0

@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _draw() -> void:
	var center: Vector2 = size * 0.5
	draw_arc(center, OUTER_RING_RADIUS, 0.0, TAU, 48, Color(0.0, 0.0, 0.0, 0.45), SHADOW_WIDTH, true)
	draw_arc(center, OUTER_RING_RADIUS, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.95), OUTER_RING_WIDTH, true)
	draw_circle(center, CENTER_DOT_RADIUS, Color(1.0, 1.0, 1.0, 0.95), true, -1.0, true)


func enlarge() -> void:
	_animation_player.play("enhance")


func shrink() -> void:
	_animation_player.play_backwards("enhance")


func show_reticle() -> void:
	_animation_player.play("show")


func hide_reticle() -> void:
	_animation_player.play_backwards("show")
