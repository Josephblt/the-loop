class_name SpawnRoom
extends Room


signal room_deactivated


func get_room_id() -> String:
	return "spawn_room"


func _on_activator_body_exited(body: Node3D) -> void:
	if body is Player:
		room_deactivated.emit()
