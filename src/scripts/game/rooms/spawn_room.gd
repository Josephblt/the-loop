class_name SpawnRoom
extends Node3D


var _memory: Memory
var _player: Player


func _ready() -> void:
	_setup_fire_fixtures()


func setup_scene(player: Player, memory: Memory) -> void:
	_player = player
	_memory = memory


func _setup_fire_fixtures() -> void:
	if !_memory:
		return

	var fixture_nodes: Array[Node] = find_children("*", "", true, false)
	for fixture_node: Node in fixture_nodes:
		if !(fixture_node is FireFixture):
			continue

		var fixture: FireFixture = fixture_node as FireFixture
		var fixture_path: String = str(get_path_to(fixture))

		if _memory.has_fire_fixture_state(fixture_path):
			fixture.set_lit(_memory.get_fire_fixture_state(fixture_path))

		fixture.lit_changed.connect(_on_fire_fixture_lit_changed.bind(fixture_path))


func _on_fire_fixture_lit_changed(is_lit: bool, fixture_path: String) -> void:
	_memory.set_fire_fixture_state(fixture_path, is_lit)
