class_name GriefStagesStack


enum GriefStages {
	DENIAL,
	ANGER,
	BARGAINING,
	DEPRESSION,
	ACCEPTANCE
}

var _available_grief_stage_stack: Array[GriefStages]


func _init(session_seed: int) -> void:
	var stages: Array[GriefStages] = []
	stages.assign(GriefStages.values())
	stages.erase(GriefStages.ACCEPTANCE)
	
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = session_seed
	ArrayRandomizer.shuffle(stages, randomizer)	

	stages.append(GriefStages.ACCEPTANCE)
	_available_grief_stage_stack = stages


func pop():
	return _available_grief_stage_stack.pop_front()
		

func serialize() -> Dictionary:
	return {
		"grief_stages_stack": {
			"available_grief_stage_stack": _available_grief_stage_stack,
		}	
	}


func deserialize(data: Dictionary) -> void:
	var grief_stages_stack_data = data.get("grief_stages_stack", {})
	_available_grief_stage_stack = grief_stages_stack_data.get("available_grief_stage_stack", [])


static func get_grief_stage_name(grief_stage: GriefStages) -> String:
	match grief_stage:
		GriefStages.DENIAL:
			return "Denial"
		GriefStages.ANGER:
			return "Anger"
		GriefStages.BARGAINING:
			return "Bargaining"
		GriefStages.DEPRESSION:
			return "Depression"
		GriefStages.ACCEPTANCE:
			return "Acceptance"	
		_:
			return "None"
	
