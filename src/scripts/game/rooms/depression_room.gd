class_name DepressionRoom
extends Node3D


func _ready() -> void:
	position.x = (int)((GameSession.GRID_SIZE + GameSession.STAGE_ROOM_SIZE) / 2.0) * 5.6
		