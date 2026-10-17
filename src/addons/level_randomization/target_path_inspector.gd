@tool
extends EditorInspectorPlugin


const BoundSceneNodePathProperty: Script = preload("bound_scene_node_path_property.gd")

var _catalog: LevelRandomizationCatalog


func _init(catalog: LevelRandomizationCatalog) -> void:
	_catalog = catalog


func _can_handle(object: Object) -> bool:
	return object is LevelTargetRandomizationBinding


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name != "target_path":
		return false

	var target: LevelTargetRandomizationBinding = object as LevelTargetRandomizationBinding
	var editor: EditorProperty = BoundSceneNodePathProperty.new(_catalog, target)
	add_property_editor(name, editor)
	return true
