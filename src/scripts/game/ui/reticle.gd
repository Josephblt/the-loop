class_name Reticle
extends Control

@export var dot_radius: float = 2.5
@export var outer_ring_radius: float = 15.0
@export var outer_ring_width: float = 2.5

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var enhancement: float = 0.0:
	set(value):
		enhancement = clampf(value, 0.0, 1.0)
		queue_redraw()


func _draw() -> void:
	var center: Vector2 = size * 0.5
	if is_zero_approx(enhancement):
		draw_circle(center, dot_radius, Color(1.0, 1.0, 1.0, 0.95), true, -1.0, true)
		return

	var radius: float = lerpf(dot_radius, outer_ring_radius, enhancement)
	var width: float = lerpf(dot_radius * 2.0, outer_ring_width, enhancement)
	draw_arc(center, radius, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.95), width, true)


func enlarge() -> void:
	_animation_player.play("enhance")


func shrink() -> void:
	_animation_player.play_backwards("enhance")


func show_reticle() -> void:
	_animation_player.play("show")


func hide_reticle() -> void:
	_animation_player.play_backwards("show")
