extends Node

# pass in card select state
func can_use(selected_cards: Array, consumable: Node) -> bool:
	
	if (consumable.is_planet()):
		return true
	
	return true
