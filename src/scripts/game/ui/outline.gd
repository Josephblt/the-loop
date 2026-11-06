class_name Outline
extends TextureRect

@onready var _outline_camera: Camera3D = %OutlineCamera3D
@onready var _outline_viewport: SubViewport = %OutlineViewport


func _ready() -> void:
	_outline_viewport.world_3d = get_viewport().world_3d
	_outline_camera.make_current()
	texture = _outline_viewport.get_texture()
	get_viewport().size_changed.connect(_sync_viewport_size)
	_sync_viewport_size()


func _process(_delta: float) -> void:
	var source_camera: Camera3D = get_viewport().get_camera_3d()
	if source_camera == null:
		return
	_sync_camera(source_camera)


func _sync_camera(source_camera: Camera3D) -> void:
	_outline_camera.global_transform = source_camera.global_transform
	_outline_camera.projection = source_camera.projection
	_outline_camera.fov = source_camera.fov
	_outline_camera.size = source_camera.size
	_outline_camera.near = source_camera.near
	_outline_camera.far = source_camera.far
	_outline_camera.keep_aspect = source_camera.keep_aspect
	_outline_camera.frustum_offset = source_camera.frustum_offset
	_outline_camera.h_offset = source_camera.h_offset
	_outline_camera.v_offset = source_camera.v_offset


func _sync_viewport_size() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	_outline_viewport.size = Vector2i(viewport_size)
