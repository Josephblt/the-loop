class_name MemoryRooms
extends Node3D


const MEMORY_ROOM_HORIZONTAL_SCENE: PackedScene = preload("res://game/rooms/memory_room_horizontal.tscn")
const MEMORY_ROOM_VERTICAL_SCENE: PackedScene = preload("res://game/rooms/memory_room_vertical.tscn")


func setup_rooms(stage_layout: StageLayout) -> void:
	var room_transforms: Array[Transform3D] = stage_layout.memory_room_transforms
	for index: int in room_transforms.size():
		var angle = fposmod(room_transforms[index].basis.get_euler().y, TAU)
		var room: MemoryRoom = null
		var inverted: bool = false
		
		if is_equal_approx(angle, fposmod(0, TAU)):
			room = MEMORY_ROOM_VERTICAL_SCENE.instantiate() as MemoryRoom
		
		if is_equal_approx(angle, fposmod(deg_to_rad(90), TAU)):
			room = MEMORY_ROOM_HORIZONTAL_SCENE.instantiate() as MemoryRoom
		
		if is_equal_approx(angle, fposmod(deg_to_rad(180), TAU)):
			room = MEMORY_ROOM_VERTICAL_SCENE.instantiate() as MemoryRoom
			inverted = true
		
		if is_equal_approx(angle, fposmod(deg_to_rad(270), TAU)):
			room = MEMORY_ROOM_HORIZONTAL_SCENE.instantiate() as MemoryRoom
			inverted = true
		
		room.name = "MemoryRoom%d" % (index + 1)
		room.transform = room_transforms[index]
		room.rotation.y = 0.0
		if inverted:
			room.rotate_y(deg_to_rad(180))
		room.setup_room(stage_layout.session_seed)
		add_child(room)
