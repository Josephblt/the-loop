extends InteractionUI


func _interaction_text(interactable: Interactable) -> String:
	var fire_fixture: FireFixture = interactable as FireFixture
	if fire_fixture.is_lit():
		return interaction_2
	return interaction_1


func _supports(interactable: Interactable) -> bool:
	return interactable is FireFixture
