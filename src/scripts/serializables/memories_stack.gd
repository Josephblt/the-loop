class_name MemoriesStack


var _closing_memory: Memory
var _maze_memories: Array[Memory] = []
var _randomizer: RandomNumberGenerator


func _init(session_seed: int) -> void:
	_randomizer = RandomNumberGenerator.new()
	_randomizer.seed = session_seed


func load_story_stage(story_stage: StoryStage) -> void:
	_maze_memories.clear()
	for description: String in story_stage.maze_memories:
		_maze_memories.append(Memory.new(description))
	ArrayRandomizer.shuffle(_maze_memories, _randomizer)
	_closing_memory = Memory.new(story_stage.closing_memory)


func memory_count() -> int:
	return _maze_memories.size()


func memory_at(index: int) -> Memory:
	return _maze_memories[index]


func closing_memory() -> Memory:
	return _closing_memory


func serialize() -> Dictionary:
	var serialized_maze_memories: Array[Dictionary] = []
	for memory: Memory in _maze_memories:
		serialized_maze_memories.append(memory.serialize())

	return {
		"memories_stack": {
			"maze_memories": serialized_maze_memories,
			"closing_memory": _closing_memory.serialize(),
		}
	}


func deserialize(data: Dictionary) -> void:
	var memories_stack_data: Dictionary = data.get("memories_stack", {})
	var serialized_maze_memories: Array = memories_stack_data.get("maze_memories", [])

	_maze_memories.clear()
	for memory_data: Dictionary in serialized_maze_memories:
		var memory: Memory = Memory.new()
		memory.deserialize(memory_data)
		_maze_memories.append(memory)

	_closing_memory = Memory.new()
	_closing_memory.deserialize(memories_stack_data.get("closing_memory", {}))
