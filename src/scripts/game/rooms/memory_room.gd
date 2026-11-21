class_name MemoryRoom
extends Node3D


signal chest_opened()


const SCENE_PATH: String = "res://game/rooms/memory_room.tscn"


@export var chest: Chest
@export var fire_fixtures: Array[FireFixture] = []


static func create_rooms(parent: Node3D, room_transforms: Array[Transform3D], session_seed: int) -> Array[MemoryRoom]:
	var scene: PackedScene = load(SCENE_PATH) as PackedScene
	var rooms: Array[MemoryRoom] = []
	for index: int in room_transforms.size():
		var room: MemoryRoom = scene.instantiate() as MemoryRoom
		room.name = "MemoryRoom%d" % (index + 1)
		room.transform = room_transforms[index]
		room.setup_room(session_seed)
		parent.add_child(room)
		rooms.append(room)
	return rooms


func setup_room(session_seed: int) -> void:
	SceneRandomizer.randomize_scene(self, session_seed)


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	chest_opened.emit(chest)
