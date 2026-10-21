class_name FPS
extends Node


@onready var fps_label = %FPS


func _process(_delta):
	fps_label.text = str(Engine.get_frames_per_second()) + " FPS"