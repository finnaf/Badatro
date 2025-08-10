class_name VoucherCardData
extends CardData

enum Voucher {
	Overstock, # +1 card slot (3)
	OverstockPlus, # +1 card slot (4)
	ClearanceSale, # 25% off
	Liquidation, # 50% off
	Hone, # 2x more often
	GlowUp, #4x more often
	RerollSurplus, # reroll start 2 less
	RerollGlut, # reroll start 2 more less
	CrystalBall, # +1 consumable
	OmenGlobe, # spectral cards in arcana packs
	Telescope, # celestial packs contain most played hand
	Observatory, # planet cards give 1.5x for their hand
	Grabber, # +1 hand
	NachoTong, # +1 hand
	Wasteful, # +1 discard
	Recyclomancy, # +1 discard
	TarotMechant, # 2x tarot
	TarotTycoon, #4x tarot
	PlanetMerchant, # 2x planet
	PlanetTycoon, # 4x planet
	SeedMoney, # cap on interest raised to 10
	MoneyTree, # cap on interest raised to 20
	Blank,
	Antimatter, # +1 joker slot
	MagicTrick, # can buy playing cards
	Illusion, # cards have enhancement, edition and/or seal
	Hieroglyph, # -1 ante, -1 hand
	Petroglyph, # -1 ante, -1 discard
	DirectorsCut, # reroll boss blind once for 10
	Retcon, # unlimited reroll
	PaintBrush, # +1 hand size
	Palette # +1 hand size
}

static var pool = [
	Voucher.Overstock,
	Voucher.ClearanceSale,
	Voucher.Hone,
	Voucher.RerollSurplus,
	Voucher.CrystalBall,
	Voucher.Telescope,
	Voucher.Observatory,
	Voucher.Grabber,
	Voucher.Wasteful,
	Voucher.TarotMechant,
	Voucher.PlanetMerchant,
	Voucher.SeedMoney,
	Voucher.Blank,
	Voucher.MagicTrick,
	Voucher.Hieroglyph,
	Voucher.DirectorsCut,
	Voucher.PaintBrush
]

static var discount_rate
static var extra_shop_slots

static func _static_init():
	discount_rate 		= 1
	extra_shop_slots		= 0

func _init(shop_rng: RandomNumberGenerator):
	if (pool.size() == 0):
		id = Voucher.Blank
	
	var index = shop_rng.randi() % pool.size()
	var id = pool[index]
	set_shop_card()

func use():
	match id:
		Voucher.Overstock:
			extra_shop_slots = 1
		Voucher.OverstockPlus:
			extra_shop_slots = 2
		Voucher.ClearanceSale:
			discount_rate = 0.75
		Voucher.Liquidation:
			discount_rate = 0.5


func get_cost() -> int:	
	var cost = 10
		
	cost = floor(cost * VoucherCardData.discount_rate)
	if cost < 1:
		return 1
	return cost

func is_voucher() -> bool:
	return true

static func get_voucher_name(id: Voucher) -> String:
	match id:
		Voucher.Overstock:
			return "Overstock"
		Voucher.OverstockPlus:
			return "OverstockPlus"
		Voucher.ClearanceSale:
			return "ClearanceSale"
		Voucher.Liquidation:
			return "Liquidation"
		_:
			return "Blank"
