@tool
class_name Gate
extends Node3D


const OUTLINE_SCALE: float = 1.035

@onready var _portal_surface: CSGPolygon3D = $Barrier/CSGPolygon3D
@onready var _outline_outer: CSGPolygon3D = $Barrier/PortalOutline/Outer
@onready var _outline_inner: CSGPolygon3D = $Barrier/PortalOutline/Inner


func _ready() -> void:
	_sync_outline_polygon()


func _sync_outline_polygon() -> void:
	var polygon: PackedVector2Array = _portal_surface.polygon
	if polygon.is_empty():
		return

	_outline_outer.polygon = polygon
	_outline_inner.polygon = polygon

	var center: Vector2 = _get_polygon_bounds(polygon).get_center()
	_outline_outer.scale = Vector3(OUTLINE_SCALE, OUTLINE_SCALE, 1.0)
	_outline_outer.position = Vector3(center.x, center.y, 0.0) * (1.0 - OUTLINE_SCALE)


func _get_polygon_bounds(polygon: PackedVector2Array) -> Rect2:
	var bounds: Rect2 = Rect2(polygon[0], Vector2.ZERO)
	for point: Vector2 in polygon:
		bounds = bounds.expand(point)

	return bounds
