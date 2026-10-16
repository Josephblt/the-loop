@tool
extends EditorPlugin


const RandomizationInspector = preload("randomization_inspector.gd")

var _inspector: EditorInspectorPlugin


func _enter_tree() -> void:
	_inspector = RandomizationInspector.new(get_undo_redo())
	add_inspector_plugin(_inspector)


func _exit_tree() -> void:
	if _inspector == null:
		return

	remove_inspector_plugin(_inspector)
	_inspector = null
