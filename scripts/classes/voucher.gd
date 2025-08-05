class_name VoucherCardData
extends CardData

func _init(pool: Array, rng: RandomNumberGenerator, force_id: int):
	if (force_id != -1):
		id = force_id
		set_shop_card()
		return
	
	if (pool.size() == 0):
		id = VoucherManager.Voucher.Blank
	
	var index = rng.randi() % pool.size()
	var id = pool[index]
	set_shop_card()

func use():
	pass

func get_cost(discount_percent: float) -> int:	
	var cost = 10
		
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_voucher() -> bool:
	return true
