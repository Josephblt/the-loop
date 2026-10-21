@tool
class_name BarrierEdge
extends Node3D


@export_range(0.01, 0.75, 0.01) var mesh_width: float = 0.45:
	set(value):
		mesh_width = maxf(value, 0.01)
		if is_node_ready():
			refresh()

@export var source_polygon: CSGPolygon3D
@export var edge_material: Material:
	set(value):
		edge_material = value
		if is_instance_valid(_mesh_instance):
			_mesh_instance.material_override = edge_material

var _last_polygon: PackedVector2Array = PackedVector2Array()
var _last_depth: float = -1.0
var _mesh_instance: MeshInstance3D


func _ready() -> void:
	refresh()
	set_process(Engine.is_editor_hint())


func _process(_delta: float) -> void:
	if source_polygon == null:
		return
	if source_polygon.polygon == _last_polygon and is_equal_approx(source_polygon.depth, _last_depth):
		return
	refresh()


func refresh() -> void:
	if source_polygon == null:
		return
	_ensure_mesh_instance()
	_last_polygon = source_polygon.polygon.duplicate()
	_last_depth = source_polygon.depth
	_mesh_instance.mesh = BarrierEdgeMesh.create(_last_polygon, mesh_width, _last_depth)


func _ensure_mesh_instance() -> void:
	if is_instance_valid(_mesh_instance):
		return
	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "Mesh"
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh_instance.material_override = edge_material
	add_child(_mesh_instance, false, Node.INTERNAL_MODE_BACK)
