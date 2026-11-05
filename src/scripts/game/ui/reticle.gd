class_name Reticle
extends Control

const DOT_RADIUS: float = 2.5
const OUTER_RING_RADIUS: float = 9.0
const OUTER_RING_WIDTH: float = 2.0
const SHADOW_PADDING: float = 2.0

@export_range(0.0, 1.0, 0.01) var enhancement: float = 0.0:
	set(value):
		enhancement = clampf(value, 0.0, 1.0)
		queue_redraw()

@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _draw() -> void:
	var center: Vector2 = size * 0.5
	if is_zero_approx(enhancement):
		draw_circle(center, DOT_RADIUS + SHADOW_PADDING * 0.5, Color(0.0, 0.0, 0.0, 0.45), true, -1.0, true)
		draw_circle(center, DOT_RADIUS, Color(1.0, 1.0, 1.0, 0.95), true, -1.0, true)
		return

	var radius: float = lerpf(DOT_RADIUS, OUTER_RING_RADIUS, enhancement)
	var width: float = lerpf(DOT_RADIUS * 2.0, OUTER_RING_WIDTH, enhancement)
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.0, 0.0, 0.0, 0.45), width + SHADOW_PADDING, true)
	draw_arc(center, radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.95), width, true)


func enlarge() -> void:
	_animation_player.play("enhance")


func shrink() -> void:
	_animation_player.play_backwards("enhance")


func show_reticle() -> void:
	_animation_player.play("show")


func hide_reticle() -> void:
	_animation_player.play_backwards("show")
