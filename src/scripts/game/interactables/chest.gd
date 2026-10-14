class_name Chest
extends Node3D


signal interaction_enabled()
signal interaction_disabled()
signal interaction_triggered()exit


const OUTLINE_LAYER: int = 3

@onready var chest_animations: AnimationPlayer = %AnimationPlayer
@onready var chest_cover: MeshInstance3D = %MeshInstance3DCover
@onready var chest_base: MeshInstance3D = %MeshInstance3DBase

var _is_interactable: bool = true


func _ready() -> void:
	_update_outline(false)


func _open_chest() -> void:
	chest_animations.play("open")


func _update_outline(enabled: bool) -> void:
	chest_cover.set_layer_mask_value(OUTLINE_LAYER, enabled)
	chest_base.set_layer_mask_value(OUTLINE_LAYER, enabled)


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
	_open_chest()