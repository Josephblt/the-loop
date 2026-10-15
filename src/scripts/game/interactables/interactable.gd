@abstract
class_name Interactable
extends StaticBody3D


signal interaction_enabled()
signal interaction_disabled()
signal interaction_triggered()


const OUTLINE_LAYER: int = 2

@export var outline_meshes: Array[MeshInstance3D] = []

@onready var interaction_animations: AnimationPlayer = %InteractionAnimations

var _is_interactable: bool = true


func _ready() -> void:
	_update_outline(false)


@abstract
func _interact() -> void


func _update_outline(enabled: bool) -> void:
	for mesh in outline_meshes:
		mesh.set_layer_mask_value(OUTLINE_LAYER, enabled)


func enable_interaction() -> void:
	if !_is_interactable:
		return
		
	_update_outline(true)
	interaction_animations.play("enable_interaction")
	interaction_enabled.emit()


func disable_interaction() -> void:
	if !_is_interactable:
		return
	
	_update_outline(false)
	interaction_animations.play("disable_interaction")
	interaction_disabled.emit()


func trigger_interaction() -> void:
	if !_is_interactable:
		return

	disable_interaction()
	# _is_interactable = false
	interaction_triggered.emit()
	_interact()
