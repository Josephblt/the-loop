extends Camera3D

@onready var interactables_viewport: SubViewport = %InteractablesViewport
@onready var interactables_camera: Camera3D = %InteractablesCamera3D
@onready var outline_texture_rect: TextureRect = %OutlineTextureRect
@onready var highlight_texture_rect: TextureRect = %InteractablesTextureRect


func _ready() -> void:
	interactables_viewport.world_3d = get_viewport().world_3d
	interactables_camera.make_current()

	outline_texture_rect.texture = interactables_viewport.get_texture()
	highlight_texture_rect.texture = interactables_viewport.get_texture()

	get_viewport().size_changed.connect(_sync_interactables_viewport_size)

	_sync_interactables_viewport_size()
	_sync_interactables_camera()


func _process(_delta: float) -> void:
	_sync_interactables_camera()


func _sync_interactables_camera() -> void:
	interactables_camera.global_transform = global_transform
	interactables_camera.projection = projection
	interactables_camera.fov = fov
	interactables_camera.size = size
	interactables_camera.near = near
	interactables_camera.far = far
	interactables_camera.keep_aspect = keep_aspect
	interactables_camera.frustum_offset = frustum_offset
	interactables_camera.h_offset = h_offset
	interactables_camera.v_offset = v_offset


func _sync_interactables_viewport_size() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	interactables_viewport.size = Vector2i(viewport_size)