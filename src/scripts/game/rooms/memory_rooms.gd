class_name MemoryRooms
extends Node3D


signal chest_opened(chest_index: int)
signal all_chests_opened()

const MEMORY_ROOM_HORIZONTAL_SCENE: PackedScene = preload("res://game/rooms/memory_room_horizontal.tscn")
const MEMORY_ROOM_VERTICAL_SCENE: PackedScene = preload("res://game/rooms/memory_room_vertical.tscn")

var _rooms_count: int = 0


func setup_rooms(stage_layout: StageLayout) -> void:
	var room_transforms: Array[Transform3D] = stage_layout.memory_room_transforms
	_rooms_count = room_transforms.size()
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
		room.setup_room(stage_layout.session_seed, index)
		room.chest_opened.connect(_on_chest_opened)
		add_child(room)


func _on_chest_opened(chest_index: int) -> void:
	chest_opened.emit(chest_index)
	_rooms_count -= 1
	if _rooms_count == 0:
		all_chests_opened.emit()
