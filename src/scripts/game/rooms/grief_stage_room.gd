class_name GriefStageRoom
extends Node3D

signal player_entered(grief_state_room: GriefStageRoom)
signal player_exited(grief_state_room: GriefStageRoom)
signal chest_opened()


@export var chest_gold: ChestGold
@export var enemy: Enemy
@export var fire_fixtures: Array[FireFixture] = []
@export var gates: Array[Gate] = []
@export var grief_stage: GriefStagesStack.GriefStages

var _gate_flags: Array[bool]:
	get:
		var flags: Array[bool] = []
		for index: int in gates.size():
			flags.append(gates[index].is_open)
		return flags
var _fire_fixture_flags: Array[bool]:
	get:
		var flags: Array[bool] = []
		for index: int in fire_fixtures.size():
			flags.append(fire_fixtures[index].is_ignited)
		return flags


func setup_room(stage_layout: StageLayout, data: Dictionary) -> void:
	match(grief_stage):
		GriefStagesStack.GriefStages.ANGER:
			transform = stage_layout.anger_room_transform
		GriefStagesStack.GriefStages.DENIAL:
			transform = stage_layout.denial_room_transform
		GriefStagesStack.GriefStages.BARGAINING:
			transform = stage_layout.bargaining_room_transform
		GriefStagesStack.GriefStages.DEPRESSION:
			transform = stage_layout.depression_room_transform

	_setup_gates(data)
	_setup_fire_fixtures(data)
	
	
	SceneRandomizer.randomize_scene(self, stage_layout.session_seed)


func _setup_gates(data: Dictionary) -> void:
	if data.is_empty():
		return

	var gate_flags: Array[bool] = data["gate_flags"]
	for index: int in gates.size():
		if gate_flags[index]:
			gates[index].open(true)
		else:
			gates[index].close(true)


func _setup_fire_fixtures(data: Dictionary) -> void:
	if data.is_empty():
		return

	var fire_fixture_flags: Array[bool] = data["fire_fixture_flags"]	
	for index: int in fire_fixtures.size():
		if fire_fixture_flags[index]:
			fire_fixtures[index].ignite()
		else:
			fire_fixtures[index].extinguish()


func materialize_chest() -> void:
	chest_gold.materialize()


func dissolve_chest() -> void:
	chest_gold.dissolve()


func enemy_appear() -> void:
	enemy.appear()


func enemy_disappear() -> void:
	enemy.disappear()


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


func serialize_grief_stage_room() -> Dictionary:
	return {
		"gate_flags": _gate_flags,
		"fire_fixture_flags": _fire_fixture_flags,
		"chest_materialized": chest_gold.visible,
		"enemy_visible": enemy.visible
	}
	

func _on_chest_interaction_triggered(_interactable: Interactable) -> void:
	chest_opened.emit()


func _on_player_exited(_body: Node3D) -> void:
	player_exited.emit(self)


func _on_player_entered(_body: Node3D) -> void:
	player_entered.emit(self)