class_name ConsumableCardData
extends CardData

var consumable_type: ConsumableManager.ConsumableType

func _init(type: ConsumableManager.ConsumableType):
	consumable_type = type
	id = randi_range(0, 21)

func get_cost(discount_percent: float) -> int:	
	var cost = 0
	
	if (consumable_type == ConsumableManager.ConsumableType.spectral):
		cost += 4
	else:
		cost += 3
				
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_consumable() -> bool:
	return true
func is_planet() -> bool:
	if (consumable_type == ConsumableManager.ConsumableType.planet):
		return true
	return false
