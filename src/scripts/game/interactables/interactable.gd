@abstract
class_name Interactable
extends Node3D


signal interaction_enabled()
signal interaction_disabled()
signal interaction_triggered()
signal _interaction_performed()


const OUTLINE_LAYER: int = 2
const HIGHLIGHT_MATERIAL: ShaderMaterial = preload("uid://dehlmi65vnf1q")

@export var interactable_meshes: Array[GeometryInstance3D] = []
@export var one_shot: bool = false
@export var interaction_distance: float = 5.0

@onready var interaction_animation_player: AnimationPlayer = %InteractionAnimationPlayer

var _is_interactable: bool = true


func _ready() -> void:
	_update_outline(false)
	_update_highlight(true)


@abstract
func _interact() -> void


func _update_outline(enabled: bool) -> void:
	for mesh in interactable_meshes:
		mesh.set_layer_mask_value(OUTLINE_LAYER, enabled)


func _update_highlight(enabled: bool) -> void:
	for mesh in interactable_meshes:
		if enabled:
			mesh.material_overlay = HIGHLIGHT_MATERIAL
		else:
			mesh.material_overlay = null


func enable_interaction() -> void:
	if !_is_interactable:
		return
		
	_update_outline(true)
	interaction_animation_player.play("enable_interaction")
	interaction_enabled.emit()


func disable_interaction() -> void:
	if !_is_interactable:
		return
	
	_update_outline(false)
	interaction_animation_player.play("disable_interaction")
	interaction_disabled.emit()


func trigger_interaction() -> void:
	if !_is_interactable:
		return

	if one_shot:
		disable_interaction()
		_is_interactable = false
		_update_highlight(false)

	_interact()
	await _interaction_performed
	interaction_triggered.emit()
