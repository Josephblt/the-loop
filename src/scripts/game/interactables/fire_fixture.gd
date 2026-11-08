class_name FireFixture
extends Interactable

@onready var fire: Fire = %Fire


func _interact() -> void:
	set_lit(!is_lit())
	interaction_triggered.emit(self)


func is_lit() -> bool:
	return fire.is_lit()


func set_lit(lit: bool) -> void:
	if lit:
		fire.ignite()
	else:
		fire.extinguish()
