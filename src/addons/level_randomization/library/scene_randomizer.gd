@tool
class_name SceneRandomizer


const DEFAULT_CATALOG: RandomizationCatalog = preload("res://addons/level_randomization/config/randomization_catalog.tres")


static func randomize_scene(scene_root: Node, seed: int) -> int:
	var entries: Array[RandomizationEntry] = find_entries(scene_root, DEFAULT_CATALOG)
	var randomized_count: int = 0
	print("Randomizing scene with seed: %d" % seed)
	print("Found %d entries to randomize." % entries.size())

	for entry: RandomizationEntry in entries:
		var target: Node3D = entry.target_binding.get_target(entry.node)
		var state: TransformRandomizationState = TransformRandomizer.generate(
			target.position,
			target.rotation,
			entry.target_binding.profile,
			seed,
			get_identity(scene_root, entry)
		)
		target.position = state.position
		target.rotation = state.rotation
		randomized_count += 1

	return randomized_count


static func find_entries(scene_root: Node, catalog: RandomizationCatalog) -> Array[RandomizationEntry]:
	var entries: Array[RandomizationEntry] = []
	for child: Node in scene_root.get_children():
		_find_entries_recursive(child, catalog, entries)
	return entries


static func get_identity(scene_root: Node, entry: RandomizationEntry) -> String:
	var instance_path: String = "/root/%s/%s" % [scene_root.name, scene_root.get_path_to(entry.node)]
	return "%s:%s:%s" % [entry.binding.source_scene.resource_path, instance_path, entry.target_binding.target_path]


static func _find_entries_recursive(node: Node, catalog: RandomizationCatalog, entries: Array[RandomizationEntry]) -> void:
	if node is Node3D:
		var scene_instance: Node3D = node as Node3D
		var binding: SceneRandomizationBinding = catalog.find_binding(scene_instance)
		if binding:
			for target_binding: TargetRandomizationBinding in binding.targets:
				if target_binding and target_binding.profile and target_binding.get_target(scene_instance):
					entries.append(RandomizationEntry.new(scene_instance, binding, target_binding))

	for child: Node in node.get_children():
		_find_entries_recursive(child, catalog, entries)
