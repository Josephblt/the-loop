class_name EffectCamera3D
extends Camera3D

@export var main_camera: Camera3D
@export var effect_viewport: SubViewport
@export var effect_rim_texture_rect: TextureRect


func _ready() -> void:
	effect_viewport.world_3d = main_camera.get_viewport().world_3d
	make_current()
	
	effect_rim_texture_rect.texture = effect_viewport.get_texture()
	
	get_viewport().size_changed.connect(_sync_viewport_size)

	_sync_viewport_size()
	_sync_effect_camera()


func _process(_delta: float) -> void:
	_sync_effect_camera()


func _sync_effect_camera() -> void:
	global_transform = main_camera.global_transform
	projection = main_camera.projection
	fov = main_camera.fov
	size = main_camera.size
	near = main_camera.near
	far = main_camera.far
	keep_aspect = main_camera.keep_aspect
	frustum_offset = main_camera.frustum_offset
	h_offset = main_camera.h_offset
	v_offset = main_camera.v_offset


func _sync_viewport_size() -> void:
	var viewport_size: Vector2 = main_camera.get_viewport().get_visible_rect().size
	effect_viewport.size = Vector2i(viewport_size)
