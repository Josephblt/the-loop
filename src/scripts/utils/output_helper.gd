class_name OutputHelper

static func pressClearButton() -> void:
	var shortcut:= EditorInterface.get_editor_settings().get_shortcut("editor/clear_output").get_as_text()
	var root:=EditorInterface.get_inspector().get_tree().root
	_pressClearButton(root, shortcut)


static func _pressClearButton(node:Node, shortcutText:String) -> bool:
	for i in node.get_child_count():
		var child:= node.get_child(i)
		if child is Button:
			var b:= child as Button
			if b.shortcut:
				if b.shortcut.get_as_text() == shortcutText:
					b.pressed.emit()
					return true
		if child.get_child_count() > 0:
			if _pressClearButton(child, shortcutText):
				return true
	return false