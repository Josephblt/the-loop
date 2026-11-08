extends InteractionUI


func _supports(interactable: Interactable) -> bool:
	return interactable is Chest
