class_name BarrierEdgeMesh
extends RefCounted


static func create(polygon: PackedVector2Array, width: float, depth: float) -> ArrayMesh:
	var mesh: ArrayMesh = ArrayMesh.new()
	if polygon.size() < 3 or width <= 0.0:
		return mesh

	var inward_points: PackedVector2Array = _create_inward_points(polygon, width)
	var outward_normals: PackedVector2Array = _create_outward_normals(polygon)
	var distances: PackedFloat32Array = _create_distances(polygon)
	var perimeter: float = distances[distances.size() - 1]
	var surface: SurfaceTool = SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for index: int in polygon.size():
		var next_index: int = (index + 1) % polygon.size()
		var start_offset: float = distances[index] / perimeter
		var end_offset: float = distances[index + 1] / perimeter
		_add_quad(
			surface,
			polygon[index],
			polygon[next_index],
			inward_points[next_index],
			inward_points[index],
			outward_normals[index],
			outward_normals[next_index],
			start_offset,
			end_offset,
			depth
		)

	surface.commit(mesh)
	return mesh


static func _create_inward_points(polygon: PackedVector2Array, width: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var orientation: float = 1.0 if _signed_area(polygon) > 0.0 else -1.0

	for index: int in polygon.size():
		var previous_index: int = wrapi(index - 1, 0, polygon.size())
		var next_index: int = (index + 1) % polygon.size()
		var previous_edge: Vector2 = (polygon[index] - polygon[previous_index]).normalized()
		var next_edge: Vector2 = (polygon[next_index] - polygon[index]).normalized()
		var previous_inward: Vector2 = Vector2(-previous_edge.y, previous_edge.x) * orientation
		var next_inward: Vector2 = Vector2(-next_edge.y, next_edge.x) * orientation
		var miter: Vector2 = previous_inward + next_inward

		if miter.is_zero_approx():
			points.append(polygon[index] + next_inward * width)
			continue

		miter = miter.normalized()
		var miter_scale: float = width / maxf(miter.dot(next_inward), 0.25)
		points.append(polygon[index] + miter * minf(miter_scale, width * 2.0))

	return points


static func _create_outward_normals(polygon: PackedVector2Array) -> PackedVector2Array:
	var normals: PackedVector2Array = PackedVector2Array()
	var orientation: float = 1.0 if _signed_area(polygon) > 0.0 else -1.0

	for index: int in polygon.size():
		var previous_index: int = wrapi(index - 1, 0, polygon.size())
		var next_index: int = (index + 1) % polygon.size()
		var previous_edge: Vector2 = (polygon[index] - polygon[previous_index]).normalized()
		var next_edge: Vector2 = (polygon[next_index] - polygon[index]).normalized()
		var previous_outward: Vector2 = Vector2(previous_edge.y, -previous_edge.x) * orientation
		var next_outward: Vector2 = Vector2(next_edge.y, -next_edge.x) * orientation
		var normal: Vector2 = previous_outward + next_outward
		if normal.is_zero_approx():
			normal = next_outward
		normals.append(normal.normalized())

	return normals


static func _create_distances(polygon: PackedVector2Array) -> PackedFloat32Array:
	var distances: PackedFloat32Array = PackedFloat32Array([0.0])
	for index: int in polygon.size():
		var next_index: int = (index + 1) % polygon.size()
		distances.append(distances[index] + polygon[index].distance_to(polygon[next_index]))
	return distances


static func _signed_area(polygon: PackedVector2Array) -> float:
	var area: float = 0.0
	for index: int in polygon.size():
		var next_index: int = (index + 1) % polygon.size()
		area += polygon[index].cross(polygon[next_index])
	return area * 0.5


static func _add_quad(
	surface: SurfaceTool,
	outer_start: Vector2,
	outer_end: Vector2,
	inner_end: Vector2,
	inner_start: Vector2,
	start_normal: Vector2,
	end_normal: Vector2,
	start_offset: float,
	end_offset: float,
	depth: float
) -> void:
	var front_z: float = 0.002
	var back_z: float = -depth - 0.002
	_add_vertex(surface, outer_start, start_normal, Vector2(0.0, start_offset), front_z, 1.0)
	_add_vertex(surface, outer_end, end_normal, Vector2(0.0, end_offset), front_z, 1.0)
	_add_vertex(surface, inner_end, end_normal, Vector2(1.0, end_offset), front_z, 1.0)
	_add_vertex(surface, outer_start, start_normal, Vector2(0.0, start_offset), front_z, 1.0)
	_add_vertex(surface, inner_end, end_normal, Vector2(1.0, end_offset), front_z, 1.0)
	_add_vertex(surface, inner_start, start_normal, Vector2(1.0, start_offset), front_z, 1.0)
	_add_vertex(surface, outer_start, start_normal, Vector2(0.0, start_offset), back_z, -1.0)
	_add_vertex(surface, inner_end, end_normal, Vector2(1.0, end_offset), back_z, -1.0)
	_add_vertex(surface, outer_end, end_normal, Vector2(0.0, end_offset), back_z, -1.0)
	_add_vertex(surface, outer_start, start_normal, Vector2(0.0, start_offset), back_z, -1.0)
	_add_vertex(surface, inner_start, start_normal, Vector2(1.0, start_offset), back_z, -1.0)
	_add_vertex(surface, inner_end, end_normal, Vector2(1.0, end_offset), back_z, -1.0)


static func _add_vertex(
	surface: SurfaceTool,
	point: Vector2,
	outward: Vector2,
	uv: Vector2,
	z: float,
	normal_z: float
) -> void:
	surface.set_normal(Vector3(0.0, 0.0, normal_z))
	surface.set_uv(uv)
	surface.set_uv2(outward * 0.5 + Vector2(0.5, 0.5))
	surface.add_vertex(Vector3(point.x, point.y, z))
