class_name ConsumableCardData
extends CardData

var consumable_type: CardManager.ConsumableType

func _init(type: CardManager.ConsumableType):
	consumable_type = type
	id = 0

func is_consumable() -> bool:
	return true
