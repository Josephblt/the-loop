class_name Gate
extends Node3D

const PORTAL_RIM_MASK_MATERIAL: Material = preload("res://assets/materials/effects/portal_rim_mask_material.tres")

@onready var barrier_surface: CSGPolygon3D = $Barrier/CSGPolygon3D
@onready var barrier: StaticBody3D = $Barrier


func _ready() -> void:
	var portal_rim_mask: CSGPolygon3D = barrier_surface.duplicate() as CSGPolygon3D
	portal_rim_mask.name = "PortalRimMask"
	portal_rim_mask.layers = 512
	portal_rim_mask.material = PORTAL_RIM_MASK_MATERIAL
	portal_rim_mask.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	barrier.add_child(portal_rim_mask)
