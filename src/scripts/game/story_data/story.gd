class_name Story
extends Resource


@export var title: String
@export var loops: Array[StoryLoop] = []
@export_multiline var reveal: String


func get_stage(loop_index: int, grief_stage: GriefStagesStack.GriefStages) -> StoryStage:
	assert(loop_index >= 0 and loop_index < loops.size(), "Story loop index is out of range")
	var stage: StoryStage = loops[loop_index].find_stage(grief_stage)
	assert(stage != null, "Story loop does not contain the requested grief stage")
	return stage
