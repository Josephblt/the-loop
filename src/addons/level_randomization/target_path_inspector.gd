@tool
class_name TargetPathInspector
extends EditorInspectorPlugin


const BoundSceneNodePathProperty: Script = preload("bound_scene_node_path_property.gd")

var _catalog: RandomizationCatalog


func _init(catalog: RandomizationCatalog) -> void:
	_catalog = catalog


func _can_handle(object: Object) -> bool:
	return object is TargetRandomizationBinding


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name != "target_path":
		return false

	var target: TargetRandomizationBinding = object as TargetRandomizationBinding
	var editor: EditorProperty = BoundSceneNodePathProperty.new(_catalog, target)
	add_property_editor(name, editor)
	return true
