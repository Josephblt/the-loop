extends CanvasItem

@export var supported_type: Script
@export var interaction_on: String = ""
@export var interaction_off: String = ""

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _interaction_label: Label = %LabelInteraction

var _active_interactable: Interactable


func _on_interactable_detected(interactable: Interactable) -> void:
	if supported_type == null or !supported_type.instance_has(interactable):
		return
	if _active_interactable != null and _active_interactable.interaction_triggered.is_connected(_on_interaction_triggered):
		_active_interactable.interaction_triggered.disconnect(_on_interaction_triggered)
	_active_interactable = interactable
	_active_interactable.interaction_triggered.connect(_on_interaction_triggered)
	_update_interaction_text()
	_animation_player.play("enable_interaction")


func _on_interactable_lost(interactable: Interactable) -> void:
	if interactable != _active_interactable:
		return
	if _active_interactable.interaction_triggered.is_connected(_on_interaction_triggered):
		_active_interactable.interaction_triggered.disconnect(_on_interaction_triggered)
	_active_interactable = null
	_animation_player.play("disable_interaction")


func _on_interaction_triggered(interactable: Interactable) -> void:
	if interactable != _active_interactable:
		return
	_update_interaction_text()


func _update_interaction_text() -> void:
	if _active_interactable is FireFixture:
		if _active_interactable.interaction_toggle_state():
			_interaction_label.text = interaction_on
		else:
			_interaction_label.text = interaction_off
