extends Camera3D

@onready var highlight_viewport: SubViewport = %HighlightViewport
@onready var highlight_camera: Camera3D = %HighlightCamera3D
@onready var highlight_texture_rect: TextureRect = %HighlightTextureRect
@onready var outline_viewport: SubViewport = %OutlineViewport
@onready var outline_camera: Camera3D = %OutlineCamera3D
@onready var outline_texture_rect: TextureRect = %OutlineTextureRect


func _ready() -> void:
	_initialize_effect_pass(highlight_viewport, highlight_camera, highlight_texture_rect)
	_initialize_effect_pass(outline_viewport, outline_camera, outline_texture_rect)
	get_viewport().size_changed.connect(_sync_effect_viewport_sizes)
	_sync_effect_viewport_sizes()
	_sync_effect_cameras()


func _process(_delta: float) -> void:
	_sync_effect_cameras()


func _initialize_effect_pass(viewport: SubViewport, effect_camera: Camera3D, texture_rect: TextureRect) -> void:
	viewport.world_3d = get_viewport().world_3d
	effect_camera.make_current()
	texture_rect.texture = viewport.get_texture()


func _sync_effect_cameras() -> void:
	_sync_effect_camera(highlight_camera)
	_sync_effect_camera(outline_camera)


func _sync_effect_camera(effect_camera: Camera3D) -> void:
	effect_camera.global_transform = global_transform
	effect_camera.projection = projection
	effect_camera.fov = fov
	effect_camera.size = size
	effect_camera.near = near
	effect_camera.far = far
	effect_camera.keep_aspect = keep_aspect
	effect_camera.frustum_offset = frustum_offset
	effect_camera.h_offset = h_offset
	effect_camera.v_offset = v_offset


func _sync_effect_viewport_sizes() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	highlight_viewport.size = Vector2i(viewport_size)
	outline_viewport.size = Vector2i(viewport_size)
