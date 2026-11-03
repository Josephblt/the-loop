@abstract
class_name FireFixture
extends Interactable


const IGNITE_TEXT: String = "Ignite"
const EXTINGUISH_TEXT: String = "Extinguish"

@onready var fire: Fire = %Fire
@onready var label_interaction: Label = %LabelInteraction


func _interact() -> void:
	set_lit(!is_lit())
	interaction_triggered.emit(self)


func is_lit() -> bool:
	return fire.is_lit()


func set_lit(lit: bool) -> void:
	if lit:
		fire.ignite()
		label_interaction.text = EXTINGUISH_TEXT
	else:
		fire.extinguish()
		label_interaction.text = IGNITE_TEXT
