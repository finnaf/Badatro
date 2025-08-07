class_name VoucherCardData
extends CardData

func _init(pool: Array, rng: RandomNumberGenerator):
	if (pool.size() == 0):
		id = VoucherManager.Voucher.Blank
	
	var index = rng.randi() % pool.size()
	var id = pool[index]
	set_shop_card()

func use():
	match id:
		VoucherManager.Voucher.Overstock:
			VoucherManager.use_overstock()
		VoucherManager.Voucher.OverstockPlus:
			VoucherManager.use_overstock_plus()
		VoucherManager.Voucher.ClearanceSale:
			VoucherManager.use_clearance_sale()
		VoucherManager.Voucher.Liquidation:
			VoucherManager.use_liquidation()
		

func get_cost(discount_percent: float) -> int:	
	var cost = 10
		
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_voucher() -> bool:
	return true
