class_name MemoryRooms
extends Node3D


const MEMORY_ROOM_SCENE: PackedScene = preload("res://game/rooms/memory_room.tscn")

var stage_layout: StageLayout


func setup_rooms(session_seed: int) -> void:
	var room_transforms: Array[Transform3D] = stage_layout.memory_room_transforms
	for index: int in room_transforms.size():
		var room: MemoryRoom = MEMORY_ROOM_SCENE.instantiate() as MemoryRoom
		room.name = "MemoryRoom%d" % (index + 1)
		room.transform = room_transforms[index]
		room.setup_room(session_seed)
		add_child(room)
