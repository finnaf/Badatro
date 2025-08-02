class_name BoosterCardData
extends CardData

var booster_type: CardManager.BoosterType
var booster_size: CardManager.BoosterSize

func _init():
	id = CardManager.BoosterType.buffoon
	booster_size = CardManager.BoosterSize.normal
	booster_type = CardManager.BoosterType.buffoon
	
	set_shop_card()

func get_cost(discount_percent: float) -> int:	
	var cost = 0
	
	if (booster_size == CardManager.BoosterSize.normal):
		cost += 4
	elif (booster_size == CardManager.BoosterSize.jumbo):
		cost += 6
	else: # mega
		cost += 8
		
	cost += get_edition_cost()
			
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_booster() -> bool:
	return true
