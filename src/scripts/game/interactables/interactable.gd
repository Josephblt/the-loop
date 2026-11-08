@abstract
class_name Interactable
extends Node3D

@warning_ignore("unused_signal")
signal interaction_triggered(interactable: Interactable)


const OUTLINE_LAYER: int = 2
const HIGHLIGHT_MATERIAL: ShaderMaterial = preload("uid://dehlmi65vnf1q")

@export var interactable_meshes: Array[GeometryInstance3D] = []
@export var one_shot: bool = false
@export var interaction_distance: float = 5.0

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


func disable_interaction() -> void:
	if !_is_interactable:
		return
	
	_update_outline(false)


func is_interactable() -> bool:
	return _is_interactable


func trigger_interaction(execute_interact: bool = true) -> void:
	if !_is_interactable:
		return

	if one_shot:
		disable_interaction()
		_is_interactable = false
		_update_highlight(false)
	
	if execute_interact:
		_interact()
