class_name MemoryReveal
extends CanvasLayer


signal dismissed()


@onready var memory_label: Label = %MemoryLabel
@onready var animations: AnimationPlayer = %AnimationPlayer


func _process(_delta: float) -> void:
	if animations.current_animation != "show" and Input.is_action_just_pressed("Interact"):
		dismiss()


func reveal(memory_text: String) -> void:
	memory_label.text = memory_text
	show()
	animations.play("show")


func dismiss() -> void:
	if not visible or animations.current_animation == "hide":
		return

	animations.play("hide")


func _on_animations_animation_finished(animation_name: StringName) -> void:
	if animation_name == "hide":
		hide()
		dismissed.emit()
