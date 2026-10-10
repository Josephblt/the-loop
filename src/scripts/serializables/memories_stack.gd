class_name MemoriesStack


const DENIAL_MEMORIES: Array[String] = [
	"Denial Memories 1",
	"Denial Memories 2",
	"Denial Memories 3"
]

const ANGER_MEMORIES: Array[String] = [
	"Anger Memories 1",
	"Anger Memories 2",
	"Anger Memories 3"
]

const BARGAINING_MEMORIES: Array[String] = [
	"Bargaining Memories 1",
	"Bargaining Memories 2",
	"Bargaining Memories 3"
]

const DEPRESSION_MEMORIES: Array[String] = [
	"Depression Memories 1",
	"Depression Memories 2",
	"Depression Memories 3"
]

const ACCEPTANCE_MEMORIES: Array[String] = [
	"Acceptance Memories 1",
	"Acceptance Memories 2",
	"Acceptance Memories 3"
]

var _memories_stack: Array[String]
var _randomizer: RandomNumberGenerator


func _init(session_seed: int) -> void:
	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = session_seed


func pop() -> String:
	return _memories_stack.pop_front()


func serialize() -> Dictionary:
	return {
		"memories_stack": {
			"_memories_stack": _memories_stack,
		}
	}


func deserialize(data: Dictionary) -> void:
	var memories_stack_data = data.get("memories_stack", {})
	_memories_stack = memories_stack_data.get("_memories_stack", [])


func load_grief_stack(grief_stage: GriefStagesStack.GriefStages) -> void:
	match grief_stage:
		GriefStagesStack.GriefStages.DENIAL:
			_memories_stack = DENIAL_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.ANGER:
			_memories_stack = ANGER_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.BARGAINING:
			_memories_stack = BARGAINING_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.DEPRESSION:
			_memories_stack = DEPRESSION_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.ACCEPTANCE:
			_memories_stack = ACCEPTANCE_MEMORIES.duplicate()
	
	ArrayRandomizer.shuffle(_memories_stack, _randomizer)