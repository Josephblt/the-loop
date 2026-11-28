class_name EnemyBehaviour
extends Node


signal state_changed(state: String)


var _enemy: Enemy
var _player: Player
var _state: String = "Wander"
var state: String:
	get:
		return _state


func setup(enemy: Enemy, player: Player) -> void:
	_enemy = enemy
	_player = player


func set_state(next_state: String) -> void:
	if _state == next_state:
		return
	_state = next_state
	state_changed.emit(_state)
