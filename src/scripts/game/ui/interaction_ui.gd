extends MarginContainer

@export_group("Fire Fixture")
@export var fire_fixture_interaction_1: String = "Ignite"
@export var fire_fixture_interaction_2: String = "Extinguish"

@export_group("Chest")
@export var chest_interaction_1: String = "Open Chest"

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _interaction_label: Label = %LabelInteraction

var _active_interactable: Interactable


func _on_interactable_detected(interactable: Interactable) -> void:
	_disconnect_active_interactable()
	_active_interactable = interactable
	_active_interactable.interaction_triggered.connect(_on_interaction_triggered)
	_update_interaction_text()
	_animation_player.play("enable_interaction")


func _on_interactable_lost(interactable: Interactable) -> void:
	if interactable != _active_interactable:
		return
	_disconnect_active_interactable()
	_animation_player.play("disable_interaction")


func _on_interaction_triggered(interactable: Interactable) -> void:
	if interactable != _active_interactable:
		return
	_update_interaction_text()


func _update_interaction_text() -> void:
	_interaction_label.text = _interaction_text(_active_interactable)


func _interaction_text(interactable: Interactable) -> String:
	if interactable is FireFixture:
		var fire_fixture: FireFixture = interactable as FireFixture
		if fire_fixture.is_lit():
			return fire_fixture_interaction_2
		return fire_fixture_interaction_1
	if interactable is Chest:
		return chest_interaction_1
	return ""


func _disconnect_active_interactable() -> void:
	if _active_interactable == null:
		return
	if _active_interactable.interaction_triggered.is_connected(_on_interaction_triggered):
		_active_interactable.interaction_triggered.disconnect(_on_interaction_triggered)
	_active_interactable = null
