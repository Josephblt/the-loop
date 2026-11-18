class_name GriefStageRoom
extends Node3D

signal player_died()
signal player_entered()
signal player_exited()
signal chest_opened()


const STAGE_LAYOUT_PATH: StageLayout = preload("res://assets/configs/stage_layout.tres")

@export var chest_gold: Chest
@export var enemy: Enemy
@export var fire_fixtures: Array[FireFixture] = []
@export var gates: Array[Gate] = []
@export var grief_stage: GriefStagesStack.GriefStages


func setup_room(session_seed: int) -> void:
	match(grief_stage):
		GriefStagesStack.GriefStages.ANGER:
			transform = STAGE_LAYOUT_PATH.anger_room_transform
		GriefStagesStack.GriefStages.DENIAL:
			transform = STAGE_LAYOUT_PATH.denial_room_transform
		GriefStagesStack.GriefStages.BARGAINING:
			transform = STAGE_LAYOUT_PATH.bargaining_room_transform
		GriefStagesStack.GriefStages.DEPRESSION:
			transform = STAGE_LAYOUT_PATH.depression_room_transform
		
	SceneRandomizer.randomize_scene(self, session_seed)


func materialize_chest() -> void:
	chest_gold.materialize()


func dissolve_chest() -> void:
	chest_gold.dissolve()


func hide_enemy() -> void:
	enemy.hide()


func show_enemy() -> void:
	enemy.show()


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


func _setup_fire_fixtures() -> void:
	pass	


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	chest_opened.emit()


func _on_player_exited(_body: Node3D) -> void:
	player_exited.emit()


func _on_player_entered(_body: Node3D) -> void:
	player_entered.emit()