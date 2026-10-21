@tool
class_name Gate
extends Node3D


@export_range(0.01, 0.5, 0.01) var barrier_edge_mesh_width: float = 0.2:
	set(value):
		barrier_edge_mesh_width = maxf(value, 0.01)
		if is_node_ready():
			refresh_barrier_edge()

@export var barrier_polygon: CSGPolygon3D
@export var barrier_edge_material: Material

var _last_polygon: PackedVector2Array = PackedVector2Array()
var _barrier_edge: MeshInstance3D


func _ready() -> void:
	refresh_barrier_edge()
	set_process(Engine.is_editor_hint())


func _process(_delta: float) -> void:
	if barrier_polygon == null or barrier_polygon.polygon == _last_polygon:
		return
	refresh_barrier_edge()


func refresh_barrier_edge() -> void:
	if barrier_polygon == null:
		return
	_ensure_barrier_edge()
	_last_polygon = barrier_polygon.polygon.duplicate()
	_barrier_edge.mesh = BarrierEdgeMesh.create(_last_polygon, barrier_edge_mesh_width)


func _ensure_barrier_edge() -> void:
	if is_instance_valid(_barrier_edge):
		return
	_barrier_edge = MeshInstance3D.new()
	_barrier_edge.name = "BarrierEdge"
	_barrier_edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_barrier_edge.material_override = barrier_edge_material
	barrier_polygon.add_child(_barrier_edge, false, Node.INTERNAL_MODE_BACK)
