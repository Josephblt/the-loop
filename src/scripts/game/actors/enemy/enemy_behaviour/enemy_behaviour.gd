class_name EnemyBehaviour
extends Node


var _enemy: Enemy
var _player: Player


func setup(enemy: Enemy, player: Player) -> void:
	_enemy = enemy
	_player = player
