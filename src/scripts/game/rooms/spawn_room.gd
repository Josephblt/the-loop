class_name SpawnRoom
extends Room


signal room_deactivated


func _init() -> void:
	room_id = "spawn_room"


func _on_activator_body_exited(body: Node3D) -> void:
	if body is Player:
		room_deactivated.emit()
