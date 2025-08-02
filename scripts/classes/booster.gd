class_name BoosterCardData
extends CardData

var booster_type: CardManager.BoosterType
var booster_size: CardManager.BoosterSize

func _init():
	id = CardManager.BoosterType.buffoon
	booster_size = CardManager.BoosterSize.normal
	booster_type = CardManager.BoosterType.buffoon
	
	set_shop_card()

func is_booster() -> bool:
	return true
