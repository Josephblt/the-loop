class_name InlineFlowEffect
extends CSGPolygon3D


const INLINE_FLOW_MASK_MATERIAL: Material = preload("res://assets/materials/effects/inline_flow_mask_material.tres")
const INLINE_FLOW_LAYER_BIT_VALUE = 8


func _ready() -> void:
	call_deferred("create_inline_flow_mask")


func create_inline_flow_mask() -> void:
	var inline_flow_mask: CSGPolygon3D = duplicate() as CSGPolygon3D
	inline_flow_mask.set_script(null)
	inline_flow_mask.name = "InlineFlowMask"
	inline_flow_mask.layers = INLINE_FLOW_LAYER_BIT_VALUE
	inline_flow_mask.material = INLINE_FLOW_MASK_MATERIAL
	inline_flow_mask.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var parent_node: Node3D = get_parent() as Node3D
	parent_node.add_child(inline_flow_mask)
