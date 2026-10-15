class_name MemoryReveal
extends CanvasLayer


signal dismissed()


@export var dismiss_action: StringName = &"Interact"

@onready var memory_label: Label = %MemoryLabel
@onready var animations: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(dismiss_action):
		get_viewport().set_input_as_handled()
		dismiss()


func reveal(memory_text: String) -> void:
	set_process_unhandled_input(false)
	memory_label.text = memory_text
	show()
	animations.play("show")


func dismiss() -> void:
	if not visible or animations.current_animation == "hide":
		return

	set_process_unhandled_input(false)
	animations.play("hide")


func _on_animations_animation_finished(animation_name: StringName) -> void:
	match animation_name:
		"show":
			set_process_unhandled_input(true)
		"hide":
			hide()
			dismissed.emit()
