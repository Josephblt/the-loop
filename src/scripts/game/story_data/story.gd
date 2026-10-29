class_name Story
extends Resource


@export var title: String
@export var loops: Array[StoryLoop] = []
@export_multiline var reveal: String


func get_stage(loop_index: int, grief_stage: GriefStagesStack.GriefStages) -> StoryStage:
	var stage: StoryStage = loops[loop_index].find_stage(grief_stage)
	return stage
