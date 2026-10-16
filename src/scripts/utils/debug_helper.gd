class_name DebugHelper


const PLAYER_SCENE: PackedScene = preload("res://game/actors/player.tscn")
const LIGHTS_SCENE: PackedScene = preload("res://game/level/props/lights.tscn")


static func instantiate_player(parent: Node, position: Vector3) -> Player:
	var player = PLAYER_SCENE.instantiate() as Player
	player.position = position
	parent.add_child(player)
	return player


static func instantiate_lights(parent: Node) -> void:
	var lights = LIGHTS_SCENE.instantiate()
	parent.add_child(lights)