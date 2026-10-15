class_name MemoryReveal
extends CanvasLayer


signal dismissed()


const SHOW_ANIMATION: StringName = &"show"
const HIDE_ANIMATION: StringName = &"hide"

@export var dismiss_action: StringName = &"Interact"

@onready var memory_label: Label = %MemoryLabel
@onready var animations: AnimationPlayer = %Animations


func _ready() -> void:
	set_process_unhandled_input(false)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(dismiss_action):
		get_viewport().set_input_as_handled()
		dismiss()


func reveal(memory_text: String) -> void:
	set_process_unhandled_input(false)
	memory_label.text = memory_text
	show()
	animations.play(SHOW_ANIMATION)


func dismiss() -> void:
	if not visible or animations.current_animation == HIDE_ANIMATION:
		return

	set_process_unhandled_input(false)
	animations.play(HIDE_ANIMATION)


func _on_animations_animation_finished(animation_name: StringName) -> void:
	match animation_name:
		SHOW_ANIMATION:
			set_process_unhandled_input(true)
		HIDE_ANIMATION:
			hide()
			dismissed.emit()
