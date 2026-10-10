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

var _memories_stack: Array[Memory]
var _randomizer: RandomNumberGenerator


func _init(session_seed: int) -> void:
	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = session_seed


func fetch_memory(chest_id: int) -> Memory:
	if chest_id < 0 or chest_id >= _memories_stack.size():
		return null

	return _memories_stack[chest_id].reveal()


func serialize() -> Dictionary:
	var serialized_memories_stack: Array[Dictionary] = []
	for memory in _memories_stack:
		serialized_memories_stack.append(memory.serialize())

	return {
		"memories_stack": {
			"_memories_stack": serialized_memories_stack,
		}
	}


func deserialize(data: Dictionary) -> void:
	var memories_stack_data = data.get("memories_stack", {})
	var serialized_memories_stack: Array = memories_stack_data.get("_memories_stack", [])

	_memories_stack = []
	for memory_data in serialized_memories_stack:
		var memory: Memory = Memory.new()
		memory.deserialize(memory_data)
		_memories_stack.append(memory)


func load_grief_stack(grief_stage: GriefStagesStack.GriefStages) -> void:
	var memory_descriptions: Array[String] = []

	match grief_stage:
		GriefStagesStack.GriefStages.DENIAL:
			memory_descriptions = DENIAL_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.ANGER:
			memory_descriptions = ANGER_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.BARGAINING:
			memory_descriptions = BARGAINING_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.DEPRESSION:
			memory_descriptions = DEPRESSION_MEMORIES.duplicate()
		GriefStagesStack.GriefStages.ACCEPTANCE:
			memory_descriptions = ACCEPTANCE_MEMORIES.duplicate()
	
	_memories_stack = []
	for memory_description in memory_descriptions:
		_memories_stack.append(Memory.new(memory_description))

	ArrayRandomizer.shuffle(_memories_stack, _randomizer)
