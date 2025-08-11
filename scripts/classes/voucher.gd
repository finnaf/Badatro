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

static var discount_rate				: int
static var extra_shop_slots				: int
static var extra_edition_rate			: int
static var reroll_subtraction			: int
static var extra_consumable				: int
static var spectral_shop				: bool
static var do_telescope					: bool
static var do_observatory				: bool
static var extra_hands					: int
static var extra_discards				: int
static var tarot_rate					: int
static var planet_rate					: int
static var interest_cap					: int
static var extra_joker_slots			: int
static var playing_card_shop			: bool
static var enhanced_playing_card_shop	: bool
static var do_hieroglyph				: bool # flag gets reset
static var do_petroglyph				: bool # flag gets reset
static var can_reroll					: bool
static var can_infinite_reroll			: bool
static var extra_hand_size				: int


static func _static_init():
	pool = START_POOL.duplicate()
	
	discount_rate 				= 1
	extra_shop_slots			= 0
	extra_edition_rate			= 0
	reroll_subtraction			= 0
	extra_consumable			= 0
	spectral_shop				= false
	do_telescope				= false
	do_observatory				= false
	extra_hands					= 0
	extra_discards				= 0
	tarot_rate					= 1
	planet_rate					= 1
	interest_cap				= 5
	extra_joker_slots			= 0
	playing_card_shop			= false
	enhanced_playing_card_shop	= false
	do_hieroglyph				= false
	do_petroglyph				= false
	can_reroll					= false
	can_infinite_reroll			= false
	extra_hand_size				= 0

static func reset_vouchers():
	_static_init()

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
			reroll_subtraction = 2
			pool.append(Voucher.RerollGlut)
		Voucher.RerollGlut:
			reroll_subtraction = 4
		Voucher.CrystalBall:
			extra_consumable = 1
			pool.append(Voucher.OmenGlobe)
		Voucher.OmenGlobe:
			spectral_shop = true
		Voucher.Telescope:
			do_telescope = true
			pool.append(Voucher.Observatory)
		Voucher.Observatory:
			do_observatory = true
		Voucher.Grabber:
			extra_hands = 1
			pool.append(Voucher.NachoTong)
		Voucher.NachoTong:
			extra_hands = 2
		Voucher.Wasteful:
			extra_discards = 1
			pool.append(Voucher.Recyclomancy)
		Voucher.Recyclomancy:
			extra_discards = 2
		Voucher.PlanetMerchant:
			planet_rate = 2
			pool.append(Voucher.PlanetTycoon)
		Voucher.PlanetTycoon:
			planet_rate = 4
		Voucher.SeedMoney:
			interest_cap = 10
			pool.append(Voucher.MoneyTree)
		Voucher.MoneyTree:
			interest_cap = 20
		Voucher.Blank:
			pool.append(Voucher.Antimatter)
		Voucher.Antimatter:
			extra_joker_slots = 1
		Voucher.MagicTrick:
			playing_card_shop = true
			pool.append(Voucher.Illusion)
		Voucher.Illusion:
			enhanced_playing_card_shop = true
		Voucher.Hieroglyph:
			do_hieroglyph = true # make sure to reset
			pool.append(Voucher.Petroglyph)
		Voucher.Petroglyph:
			do_petroglyph = true
		Voucher.DirectorsCut:
			can_reroll = true
			pool.append(Voucher.Retcon)
		Voucher.Retcon:
			can_infinite_reroll = true
		Voucher.PaintBrush:
			extra_hand_size = 1
		Voucher.Palette:
			extra_hand_size = 2
	
	pool.erase(id)

func get_cost() -> int:	
	var cost = 10
		
	cost = floor(cost * VoucherCardData.discount_rate)
	if cost < 1:
		return 1
	return cost

func is_voucher() -> bool:
	return true
