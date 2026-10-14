class_name Interactable
extends Node3D


signal interaction_enabled()
signal interaction_disabled()
signal interaction_triggered()


const OUTLINE_LAYER: int = 2

@export var chest_cover: Array[MeshInstance3D]

var _is_interactable: bool = true


func _ready() -> void:
	_update_outline(false)


func _interact() -> void:
	pass


func _update_outline(enabled: bool) -> void:
	for cover in chest_cover:
		cover.set_layer_mask_value(OUTLINE_LAYER, enabled)


func enable_interaction() -> void:
	if !_is_interactable:
		return
		
	_update_outline(true)
	interaction_enabled.emit()


func disable_interaction() -> void:
	if !_is_interactable:
		return
	
	_update_outline(false)
	interaction_disabled.emit()


func trigger_interaction() -> void:
	if !_is_interactable:
		return

	disable_interaction()
	_is_interactable = false
	interaction_triggered.emit()
	_interact()