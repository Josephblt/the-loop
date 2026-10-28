class_name StoryLoop
extends Resource


@export var title: String
@export var stages: Array[StoryStage] = []


func find_stage(grief_stage: GriefStagesStack.GriefStages) -> StoryStage:
	for stage: StoryStage in stages:
		if stage.grief_stage == grief_stage:
			return stage
	return null
