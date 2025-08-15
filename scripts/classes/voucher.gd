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
	TarotMerchant, # 2x tarot
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

static var START_POOL = [
	Voucher.Overstock,
	Voucher.ClearanceSale,
	Voucher.Hone,
	Voucher.RerollSurplus,
	Voucher.CrystalBall,
	Voucher.Telescope,
	Voucher.Observatory,
	Voucher.Grabber,
	Voucher.Wasteful,
	Voucher.TarotMerchant,
	Voucher.PlanetMerchant,
	Voucher.SeedMoney,
	Voucher.Blank,
	Voucher.MagicTrick,
	Voucher.Hieroglyph,
	Voucher.DirectorsCut,
	Voucher.PaintBrush
]

static var pool: Array

static var discount_rate				: float
static var extra_shop_slots				: int
static var extra_edition_rate			: int
static var extra_reroll_cost			: int
static var extra_consumable				: int
static var shop_spectral_rate			: int
static var do_telescope					: bool
static var do_observatory				: bool
static var extra_hands					: int
static var extra_discards				: int
static var extra_tarot_rate				: float
static var extra_planet_rate			: int
static var extra_interest_cap			: int
static var extra_joker_slots			: int
static var shop_playing_card_rate		: int
static var enhanced_playing_card_shop	: bool
static var ante_subtraction				: int
static var can_reroll					: bool
static var can_infinite_reroll			: bool
static var extra_hand_size				: int


static func _static_init():
	pool = START_POOL.duplicate()
	
	discount_rate = 1
	extra_shop_slots = 0
	extra_edition_rate = 0 # TODO
	extra_reroll_cost = 0
	extra_consumable = 0
	shop_spectral_rate = 0
	shop_playing_card_rate = 0
	do_telescope = false
	do_observatory = false
	extra_hands = 0
	extra_discards = 0
	extra_tarot_rate = 0
	extra_planet_rate = 0
	extra_interest_cap = 0
	extra_joker_slots = 0
	enhanced_playing_card_shop = false
	ante_subtraction = 0
	can_reroll = false
	can_infinite_reroll = false
	extra_hand_size = 0

static func reset_vouchers():
	_static_init()

func _init(shop_rng: RandomNumberGenerator):
	if (pool.size() == 0):
		id = Voucher.Blank
	
	var index = shop_rng.randi() % pool.size()
	id = pool[index]
	set_shop_card()
	
	# FOR TESTING
	id = Voucher.MagicTrick

func use():
	match id:
		Voucher.Overstock:
			extra_shop_slots = 1
			pool.append(Voucher.OverstockPlus)
		Voucher.OverstockPlus:
			extra_shop_slots = 2
		Voucher.ClearanceSale:
			discount_rate = 0.75
			pool.append(Voucher.Liquidation)
		Voucher.Liquidation:
			discount_rate = 0.5
		Voucher.Hone:
			extra_edition_rate = 2
			pool.append(Voucher.GlowUp)
		Voucher.GlowUp:
			extra_edition_rate = 4
		Voucher.RerollSurplus:
			extra_reroll_cost = -2
			pool.append(Voucher.RerollGlut)
		Voucher.RerollGlut:
			extra_reroll_cost = -4
		Voucher.CrystalBall:
			extra_consumable = 1
			pool.append(Voucher.OmenGlobe)
		Voucher.OmenGlobe:
			shop_spectral_rate = 4
		Voucher.Telescope:
			do_telescope = true
			pool.append(Voucher.Observatory)
		Voucher.Observatory:
			do_observatory = true
		Voucher.Grabber:
			extra_hands += 1
			pool.append(Voucher.NachoTong)
		Voucher.NachoTong:
			extra_hands += 1
		Voucher.Wasteful:
			extra_discards += 1
			pool.append(Voucher.Recyclomancy)
		Voucher.Recyclomancy:
			extra_discards += 1
		Voucher.PlanetMerchant:
			extra_planet_rate = 5.6
			pool.append(Voucher.PlanetTycoon)
		Voucher.PlanetTycoon:
			extra_planet_rate = 28
		Voucher.TarotMerchant:
			extra_tarot_rate = 5.6
			pool.append(Voucher.TarotTycoon)
		Voucher.TarotTycoon:
			extra_tarot_rate = 28
		Voucher.SeedMoney:
			extra_interest_cap += 5
			pool.append(Voucher.MoneyTree)
		Voucher.MoneyTree:
			extra_interest_cap += 10
		Voucher.Blank:
			pool.append(Voucher.Antimatter)
		Voucher.Antimatter:
			extra_joker_slots += 1
		Voucher.MagicTrick:
			shop_playing_card_rate = 4
			pool.append(Voucher.Illusion)
		Voucher.Illusion:
			enhanced_playing_card_shop = true
		Voucher.Hieroglyph:
			ante_subtraction += 1
			extra_hands -= 1
			pool.append(Voucher.Petroglyph)
		Voucher.Petroglyph:
			ante_subtraction += 1
			extra_discards -= 1
		Voucher.DirectorsCut:
			can_reroll = true
			pool.append(Voucher.Retcon)
		Voucher.Retcon:
			can_infinite_reroll = true
		Voucher.PaintBrush:
			extra_hand_size += 1
		Voucher.Palette:
			extra_hand_size += 1
	
	pool.erase(id)

func get_cost() -> int:	
	var cost = 10
		
	cost = floor(cost * VoucherCardData.discount_rate)
	if cost < 1:
		return 1
	return cost

func is_voucher() -> bool:
	return true
