class_name SettingsDebugInfo
extends RefCounted


const ROMAN_LOOP_NUMBERS: Array[String] = ["I", "II", "III"]


var collected_memories: String
var completed_grief_stages: String
var current_grief_stage: String
var loop: String
var remaining_grief_stages: String
var session_seed: String
var story_title: String


func _init(game_session: GameSession) -> void:
	var loop_index: int = game_session._loop_count
	var remaining_stages: Array[GriefStagesStack.GriefStages] = _remaining_stages(game_session._grief_stages_stack)
	var completed_stages: Array[GriefStagesStack.GriefStages] = _completed_stages(remaining_stages)

	session_seed = str(game_session._session_seed)
	story_title = game_session._story.title
	loop = "%s - %s" % [_roman_loop_number(loop_index + 1), game_session._story.loops[loop_index].title]
	current_grief_stage = "None" if remaining_stages.is_empty() else _grief_stage_name(remaining_stages[0])
	collected_memories = "%d / %d" % [_collected_memory_count(game_session._memories_stack), game_session._memories_stack.memory_count()]
	completed_grief_stages = _format_grief_stages(completed_stages)
	remaining_grief_stages = _format_grief_stages(remaining_stages)


func _remaining_stages(grief_stages_stack: GriefStagesStack) -> Array[GriefStagesStack.GriefStages]:
	var data: Dictionary = grief_stages_stack.serialize().get("grief_stages_stack", {})
	var stages: Array[GriefStagesStack.GriefStages] = []
	stages.assign(data.get("available_grief_stage_stack", []))
	return stages


func _completed_stages(remaining_stages: Array[GriefStagesStack.GriefStages]) -> Array[GriefStagesStack.GriefStages]:
	var stages: Array[GriefStagesStack.GriefStages] = []
	stages.assign(GriefStagesStack.GriefStages.values())
	for remaining_stage: GriefStagesStack.GriefStages in remaining_stages:
		stages.erase(remaining_stage)
	return stages


func _collected_memory_count(memories_stack: MemoriesStack) -> int:
	var collected_count: int = 0
	for index: int in memories_stack.memory_count():
		var memory: Memory = memories_stack.memory_at(index)
		if memory != null and memory.is_revealed():
			collected_count += 1
	return collected_count


func _format_grief_stages(stages: Array[GriefStagesStack.GriefStages]) -> String:
	if stages.is_empty():
		return "None"

	var stage_names: PackedStringArray = PackedStringArray()
	for grief_stage: GriefStagesStack.GriefStages in stages:
		stage_names.append(_grief_stage_name(grief_stage))
	return ", ".join(stage_names)


func _grief_stage_name(grief_stage: GriefStagesStack.GriefStages) -> String:
	match grief_stage:
		GriefStagesStack.GriefStages.DENIAL:
			return "Denial"
		GriefStagesStack.GriefStages.ANGER:
			return "Anger"
		GriefStagesStack.GriefStages.BARGAINING:
			return "Bargaining"
		GriefStagesStack.GriefStages.DEPRESSION:
			return "Depression"
		GriefStagesStack.GriefStages.ACCEPTANCE:
			return "Acceptance"
	return "Unknown"


func _roman_loop_number(loop_number: int) -> String:
	if loop_number > 0 and loop_number <= ROMAN_LOOP_NUMBERS.size():
		return ROMAN_LOOP_NUMBERS[loop_number - 1]
	return str(loop_number)
