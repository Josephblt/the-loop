class_name OutlineCamera3D
extends Camera3D

@onready var outline_viewport: SubViewport = %OutlineViewport
@onready var outline_camera: Camera3D = %OutlineCamera3D
@onready var outline_texture_rect: TextureRect = %OutlineTextureRect


func _ready() -> void:
	outline_viewport.world_3d = get_viewport().world_3d
	outline_camera.make_current()

	outline_texture_rect.texture = outline_viewport.get_texture()

	get_viewport().size_changed.connect(_sync_outline_viewport_size)

	_sync_outline_viewport_size()
	_sync_outline_camera()


func _process(_delta: float) -> void:
	_sync_outline_camera()


func _sync_outline_camera() -> void:
	outline_camera.global_transform = global_transform
	outline_camera.projection = projection
	outline_camera.fov = fov
	outline_camera.size = size
	outline_camera.near = near
	outline_camera.far = far
	outline_camera.keep_aspect = keep_aspect
	outline_camera.frustum_offset = frustum_offset
	outline_camera.h_offset = h_offset
	outline_camera.v_offset = v_offset


func _sync_outline_viewport_size() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	outline_viewport.size = Vector2i(viewport_size)