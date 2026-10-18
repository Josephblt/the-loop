@tool
class_name BoundSceneNodePathProperty
extends EditorProperty


const ROOT_PATH: NodePath = NodePath(".")
const TARGET_PATH_PROPERTY: StringName = "target_path"


var _catalog: RandomizationCatalog
var _dialog: ConfirmationDialog
var _path_button: Button
var _target: TargetRandomizationBinding
var _tree: Tree


func _init(catalog: RandomizationCatalog, target: TargetRandomizationBinding) -> void:
	_catalog = catalog
	_target = target

	var row: HBoxContainer = HBoxContainer.new()
	add_child(row)

	_path_button = Button.new()
	_path_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_path_button.pressed.connect(_open_picker)
	row.add_child(_path_button)

	var clear_button: Button = Button.new()
	var editor_theme: Theme = EditorInterface.get_editor_theme()
	var clear_icon: Texture2D = editor_theme.get_icon("Clear", "EditorIcons")
	clear_button.icon = clear_icon
	clear_button.tooltip_text = "Clear target path"
	clear_button.pressed.connect(_clear_path)
	row.add_child(clear_button)


func _update_property() -> void:
	var path: NodePath = _target.target_path
	if path.is_empty():
		_path_button.text = "Assign..."
	else:
		_path_button.text = _target.resource_name


func _open_picker() -> void:
	var source_scene: PackedScene = _catalog.find_source_scene(_target)
	if !source_scene:
		return

	_build_dialog(source_scene)
	_dialog.popup_centered_clamped(Vector2i(350, 700))


func _build_dialog(source_scene: PackedScene) -> void:
	if _dialog:
		_dialog.queue_free()

	_dialog = ConfirmationDialog.new()
	_dialog.title = "Select a Node from %s" % source_scene.resource_path.get_file()
	_dialog.confirmed.connect(_select_path)
	add_child(_dialog)

	_tree = Tree.new()
	_tree.custom_minimum_size = Vector2(320, 600)
	_tree.hide_root = false
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.item_activated.connect(_confirm_dialog)
	_dialog.add_child(_tree)

	var scene_root: Node = source_scene.instantiate()
	_add_node(scene_root, null, ROOT_PATH)
	scene_root.free()


func _add_node(node: Node, parent: TreeItem, path: NodePath) -> void:
	var item: TreeItem = _tree.create_item(parent)
	item.set_text(0, node.name)
	item.set_metadata(0, path)
	item.set_selectable(0, node is Node3D)
	if path == _target.target_path:
		item.select(0)

	for child: Node in node.get_children():
		var child_path: NodePath = NodePath(str(child.name))
		if path != ROOT_PATH:
			child_path = NodePath(str(path).path_join(str(child.name)))
		_add_node(child, item, child_path)


func _select_path() -> void:
	var item: TreeItem = _tree.get_selected()
	if !item:
		return

	var path: NodePath = item.get_metadata(0)
	var display_name: String = item.get_text(0)
	emit_changed(TARGET_PATH_PROPERTY, path)
	_target.resource_name = display_name
	_path_button.text = display_name


func _confirm_dialog() -> void:
	var item: TreeItem = _tree.get_selected()
	if !item or !item.is_selectable(0):
		return

	_select_path()
	_dialog.hide()


func _clear_path() -> void:
	emit_changed(TARGET_PATH_PROPERTY, NodePath())
	_target.resource_name = "Target"
	_path_button.text = "Assign..."
