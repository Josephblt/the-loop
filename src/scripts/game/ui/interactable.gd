extends MarginContainer

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
	_interaction_label.text = _active_interactable.interaction_text()


func _disconnect_active_interactable() -> void:
	if _active_interactable == null:
		return
	if _active_interactable.interaction_triggered.is_connected(_on_interaction_triggered):
		_active_interactable.interaction_triggered.disconnect(_on_interaction_triggered)
	_active_interactable = null
