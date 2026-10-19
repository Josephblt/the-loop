extends Area3D


var _collision_shapes: Array[CollisionShape3D] = []


func _ready() -> void:
	_collision_shapes = _find_sibling_collision_shapes()
	_set_collision_shapes_enabled(false)


func _find_sibling_collision_shapes() -> Array[CollisionShape3D]:
	var collision_shapes: Array[CollisionShape3D] = []
	for sibling: Node in get_parent().get_children():
		if sibling == self:
			continue

		if sibling is CollisionShape3D:
			collision_shapes.append(sibling as CollisionShape3D)

		for node: Node in sibling.find_children("*", "CollisionShape3D", true, false):
			collision_shapes.append(node as CollisionShape3D)

	return collision_shapes


func _set_collision_shapes_enabled(enabled: bool) -> void:
	for collision_shape: CollisionShape3D in _collision_shapes:
		collision_shape.set_deferred("disabled", !enabled)


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		_set_collision_shapes_enabled(true)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		_set_collision_shapes_enabled(false)
