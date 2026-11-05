class_name GriefStageRoom
extends Node3D


signal player_entered()
signal player_exited()
signal chest_opened()


@export var player: Player
@export var gates: Array[Gate] = []
@export var fire_fixtures: Array[FireFixture] = []
@export var chest_gold: Chest


func _ready() -> void:
	pass


func hide_chest() -> void:
	pass


func show_chest() -> void:
	pass


func open_gates() -> void:
	for gate: Gate in gates:
		gate.open()


func close_gates() -> void:
	for gate: Gate in gates:
		gate.close()


func ignite_fire_fixtures() -> void:
	for fixture: FireFixture in fire_fixtures:
		fixture.ignite()


func extinguish_fire_fixtures() -> void:
	for fixture: FireFixture in fire_fixtures:
		fixture.extinguish()


func _setup_chest() -> void:
	pass


func _setup_fire_fixtures() -> void:
	pass	


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	chest_opened.emit()


func _on_activator_body_entered(_body: Node3D) -> void:
	player_entered.emit()


func _on_activator_body_exited(_body: Node3D) -> void:
	player_exited.emit()
		

func _on_player_entered(_body: Node3D) -> void:
	player_entered.emit()


func _on_player_exited(_body: Node3D) -> void:
	player_exited.emit()
