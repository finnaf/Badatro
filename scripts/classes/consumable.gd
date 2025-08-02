class_name ConsumableCardData
extends CardData

var consumable_type: CardManager.ConsumableType

func _init(type: CardManager.ConsumableType):
	consumable_type = type
	id = 0

func get_cost(discount_percent: float) -> int:	
	var cost = 0
	
	if (consumable_type == CardManager.ConsumableType.spectral):
		cost += 4
	else:
		cost += 3
				
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_consumable() -> bool:
	return true
