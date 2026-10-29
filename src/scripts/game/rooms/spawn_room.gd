class_name SpawnRoom
extends Node3D


signal room_deactivated


func _on_activator_body_exited(body: Node3D) -> void:
	if body is Player:
		room_deactivated.emit()
