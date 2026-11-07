class_name FireFixture
extends Interactable

@onready var fire: Fire = %Fire


func _interact() -> void:
	set_lit(!is_lit())
	interaction_triggered.emit(self)


func is_lit() -> bool:
	return fire.is_lit()


func interaction_text() -> String:
	if is_lit():
		return interaction_2
	return interaction_1


func set_lit(lit: bool) -> void:
	if lit:
		fire.ignite()
	else:
		fire.extinguish()
