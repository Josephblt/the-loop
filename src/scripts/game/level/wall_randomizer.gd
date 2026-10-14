@tool
class_name WallRandomizer
extends LevelRandomizer


func _randomize_inversion() -> void:
	super._randomize_inversion()
	
	if _inverted:
		%MeshInstance3D.position.z += 0.6
		%CollisionShape3D.rotation_degrees.y += 180
