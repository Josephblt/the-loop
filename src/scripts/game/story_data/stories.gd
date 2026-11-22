class_name Stories
extends Resource


@export var stories: Array[Story] = []


func get_story(session_seed: int) -> Story:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = session_seed
	return stories[randomizer.randi_range(0, stories.size() - 1)]
