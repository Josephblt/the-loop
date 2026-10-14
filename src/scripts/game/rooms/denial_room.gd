class_name DenialRoom
extends Node3D


const DENIAL_ROOM_SCENE_PATH = "res://src/scenes/game/rooms/denial_room.tscn"


func _ready() -> void:
	position.z = -(int)((GameSession.GRID_SIZE + GameSession.STAGE_ROOM_SIZE) / 2.0) * 5.6


static func create() -> DenialRoom:
	var room: DenialRoom = preload(DENIAL_ROOM_SCENE_PATH).instantiate()
	return room