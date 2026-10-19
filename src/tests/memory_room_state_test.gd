extends SceneTree


const MEMORY_ROOM_SCENE: PackedScene = preload("res://game/rooms/memory_room.tscn")
const OPEN_ROTATION: float = 1.3089969


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var closed_room: MemoryRoom = await _create_room(false)
	var opened_room: MemoryRoom = await _create_room(true)
	var closed_cover: MeshInstance3D = closed_room.get_node("Memory/Chest/MeshInstance3DCover") as MeshInstance3D
	var opened_cover: MeshInstance3D = opened_room.get_node("Memory/Chest/MeshInstance3DCover") as MeshInstance3D

	if !is_zero_approx(closed_cover.rotation.z):
		printerr("Unrevealed memory chest should remain closed.")
		quit(1)
		return

	if !is_equal_approx(opened_cover.rotation.z, OPEN_ROTATION):
		printerr("Revealed memory chest should start opened.")
		quit(1)
		return

	closed_room.queue_free()
	opened_room.queue_free()
	await process_frame
	call_deferred("quit")


func _create_room(revealed: bool) -> MemoryRoom:
	var memory: Memory = Memory.new("Test memory")
	memory.revealed = revealed
	var memory_room: MemoryRoom = MEMORY_ROOM_SCENE.instantiate() as MemoryRoom
	memory_room.setup_scene(null, memory)
	root.add_child(memory_room)
	await process_frame
	return memory_room
