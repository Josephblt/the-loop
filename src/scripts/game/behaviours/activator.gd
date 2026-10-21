extends Area3D


var _collision_objects: Array[Node3D] = []


func _ready() -> void:
	_collision_objects = _find_sibling_collision_objects()
	_set_collision_objects_enabled(false)


func _find_sibling_collision_objects() -> Array[Node3D]:
	var collision_shapes: Array[Node3D] = []
	for sibling: Node in get_parent().get_children():
		if sibling == self:
			continue

		if sibling is CollisionShape3D:
			collision_shapes.append(sibling as CollisionShape3D)
		
		if sibling is CollisionPolygon3D:
			collision_shapes.append(sibling as CollisionPolygon3D)

		for node: Node in sibling.find_children("*", "CollisionShape3D", true, false):
			collision_shapes.append(node as CollisionShape3D)
		
		for node: Node in sibling.find_children("*", "CollisionPolygon3D", true, false):
			collision_shapes.append(node as CollisionPolygon3D)

	return collision_shapes


func _set_collision_objects_enabled(enabled: bool) -> void:
	for collision_shape: Node3D in _collision_objects:
		collision_shape.set_deferred("disabled", !enabled)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_set_collision_objects_enabled(true)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_set_collision_objects_enabled(false)
