class_name Fade
extends Node

signal fade_in_completed
signal fade_out_completed

@export var color: Color = Color(0.09, 0.04, 0.16)
@export var auto_start: bool = true
@export var interruptible: bool = true
@export var enable_timer: bool = true
@export var wait_time: float = 5.0
@export var fade_duration: float = 2.5

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var color_rect: ColorRect = %ColorRect
@onready var timer: Timer = $Timer

var can_fade_out: bool = false


func _ready() -> void:
	color_rect.color = color
	timer.wait_time = wait_time
	animation_player.speed_scale = 1.0 / fade_duration
	if auto_start:
		fade_in()


func _input(_event: InputEvent) -> void:
	if !interruptible:
		return

	if !can_fade_out:
		return

	if Input.is_action_just_pressed("Interact"):
		fade_out()


func fade_in() -> void:
	can_fade_out = true
	animation_player.play("fade")
	await animation_player.animation_finished
	if enable_timer:
		timer.start()
	fade_in_completed.emit()
	

func fade_out() -> void:
	can_fade_out = false
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	fade_out_completed.emit()


func _on_timer_timeout() -> void:
	if can_fade_out:
		fade_out()
