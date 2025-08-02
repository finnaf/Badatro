class_name VoucherCardData
extends CardData

func _init():
	id = 0
	set_shop_card()

func get_cost(discount_percent: float) -> int:	
	var cost = 10
		
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost
