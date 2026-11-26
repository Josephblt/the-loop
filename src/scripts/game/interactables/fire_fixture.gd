class_name FireFixture
extends Interactable


@onready var fire: Fire = %Fire

var is_lit: bool:
	get:
		return fire.is_lit()


func _interact() -> void:
	if is_lit:
		extinguish()
	else:
		ignite()
	interaction_triggered.emit(self)


func ignite() -> void:
	fire.ignite()


func extinguish() -> void:
	fire.extinguish()