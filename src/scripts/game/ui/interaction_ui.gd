extends MarginContainer

enum InteractableType {
	FIRE_FIXTURE,
	CHEST,
}

@export var interactable_type: InteractableType = InteractableType.FIRE_FIXTURE
@export var interaction_1: String = ""
@export var interaction_2: String = ""

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _interaction_label: Label = %LabelInteraction

var _active_interactable: Interactable


func _on_interactable_detected(interactable: Interactable) -> void:
	if !_supports(interactable):
		_hide_active_interaction()
		return
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
	if interactable_type == InteractableType.FIRE_FIXTURE:
		var fire_fixture: FireFixture = interactable as FireFixture
		if fire_fixture.is_lit():
			return interaction_2
	return interaction_1


func _supports(interactable: Interactable) -> bool:
	if interactable_type == InteractableType.FIRE_FIXTURE:
		return interactable is FireFixture
	return interactable is Chest


func _hide_active_interaction() -> void:
	if _active_interactable == null:
		return
	_disconnect_active_interactable()
	_animation_player.play("disable_interaction")


func _disconnect_active_interactable() -> void:
	if _active_interactable == null:
		return
	if _active_interactable.interaction_triggered.is_connected(_on_interaction_triggered):
		_active_interactable.interaction_triggered.disconnect(_on_interaction_triggered)
	_active_interactable = null
