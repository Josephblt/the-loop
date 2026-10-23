class_name InlineFlowBlurPipeline
extends Node

@export var rim_viewport: SubViewport
@export var horizontal_blur_viewport: SubViewport
@export var rim_texture_rect: TextureRect
@export var horizontal_blur_texture_rect: TextureRect
@export var output_texture_rect: TextureRect


func _ready() -> void:
	horizontal_blur_texture_rect.texture = rim_viewport.get_texture()
	output_texture_rect.texture = horizontal_blur_viewport.get_texture()
	get_viewport().size_changed.connect(_sync_viewport_sizes)
	output_texture_rect.material.changed.connect(_sync_material_parameters)
	_sync_viewport_sizes()
	_sync_material_parameters()


func _sync_viewport_sizes() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	rim_viewport.size = Vector2i(viewport_size)
	horizontal_blur_viewport.size = Vector2i(viewport_size)


func _sync_material_parameters() -> void:
	var rim_material: ShaderMaterial = rim_texture_rect.material as ShaderMaterial
	var horizontal_material: ShaderMaterial = horizontal_blur_texture_rect.material as ShaderMaterial
	var output_material: ShaderMaterial = output_texture_rect.material as ShaderMaterial
	var rim_width: float = output_material.get_shader_parameter("rim_width")
	var rim_blur: float = output_material.get_shader_parameter("rim_blur")
	rim_material.set_shader_parameter("rim_width", rim_width)
	horizontal_material.set_shader_parameter("rim_blur", rim_blur)
