class_name GriefStageRoom
extends Node3D

signal player_entered()
signal player_exited()
signal chest_opened()


@export var chest_gold: ChestGold
@export var enemy: Enemy
@export var fire_fixtures: Array[FireFixture] = []
@export var gates: Array[Gate] = []
@export var grief_stage: GriefStagesStack.GriefStages


func setup_room(stage_layout: StageLayout, gate_flags: int) -> void:
	match(grief_stage):
		GriefStagesStack.GriefStages.ANGER:
			transform = stage_layout.anger_room_transform
		GriefStagesStack.GriefStages.DENIAL:
			transform = stage_layout.denial_room_transform
		GriefStagesStack.GriefStages.BARGAINING:
			transform = stage_layout.bargaining_room_transform
		GriefStagesStack.GriefStages.DEPRESSION:
			transform = stage_layout.depression_room_transform

	_setup_gates(gate_flags)
	
	SceneRandomizer.randomize_scene(self, stage_layout.session_seed)


func _setup_gates(gate_flags: int) -> void:
	for index: int in gates.size():
		if gate_flags & (1 << index):
			gates[index].open(true)
		else:
			gates[index].close(true)


func materialize_chest() -> void:
	chest_gold.materialize()


func dissolve_chest() -> void:
	chest_gold.dissolve()


func hide_enemy() -> void:
	enemy.hide()


func show_enemy() -> void:
	enemy.show()


func open_gates(immediately: bool) -> void:
	for gate: Gate in gates:
		gate.open(immediately)	


func close_gates(immediately: bool) -> void:
	for gate: Gate in gates:
		gate.close(immediately)


func ignite_fire_fixtures() -> void:
	for fixture: FireFixture in fire_fixtures:
		fixture.ignite()


func extinguish_fire_fixtures() -> void:
	for fixture: FireFixture in fire_fixtures:
		fixture.extinguish()


func serialize_grief_stage_room() -> int:
	var flags: int = 0
	for index: int in gates.size():
		if gates[index].is_open:
			flags |= 1 << index
	return flags


func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	chest_opened.emit()


func _on_player_exited(_body: Node3D) -> void:
	player_exited.emit()


func _on_player_entered(_body: Node3D) -> void:
	player_entered.emit()