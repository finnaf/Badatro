# card_data.gd
class_name CardData
extends RefCounted

var id: int = -1
var edition: CardManager.Edition = CardManager.Edition.none
var is_shop: bool = false

func get_edition_val():
	match edition:
		CardManager.Edition.foil:
			return {"chips": 50}
		CardManager.Edition.holographic:
			return {"mult": 10}
		CardManager.Edition.polychrome:
			return {"xmult": 1.5}
		_:
			return {}

func roll_edition(rate: int, no_neg: bool, rng: RandomNumberGenerator):
	var choice = rng.randf()
	rate = 1
	
	# rate 1 = normal prob
	# rate 25 = guaranteed
	# rate 2 = hone
	# rate 4 = glow up
	
	# doesnt perfectly match, but pretty close
	if (choice > 1 - (0.003 * rate) and not no_neg):
		edition = CardManager.Edition.negative
	elif (choice > 1 - 0.006 * rate):
		edition = CardManager.Edition.polychrome
	elif (choice > 1 - 0.02 * rate):
		edition = CardManager.Edition.holographic
	elif (choice > 1 - 0.04 * rate):
		edition = CardManager.Edition.foil
	else:
		edition = CardManager.Edition.none

func get_cost(discount_percent: float) -> int:	
	return -1 # cant have cost of default cardtype

func get_edition_cost() -> int:
	if (edition == CardManager.Edition.foil):
		return 2
	elif (edition == CardManager.Edition.holographic):
		return 3
	elif (edition == CardManager.Edition.polychrome or
		edition == CardManager.Edition.negative):
			return 5
	return 0

func get_sell_price(discount_percent: float) -> int:
	var price = floori(get_cost(discount_percent) / 2)
	print(price)
	if price < 1:
		return 1
	return price

func set_shop_card():
	is_shop = true
func unset_shop_card():
	is_shop = false

func is_joker() -> bool:
	return false
func is_playing_card() -> bool:
	return false
func is_booster() -> bool:
	return false
func is_consumable() -> bool:
	return false
func is_planet() -> bool:
	return false
func is_voucher() -> bool:
	return false
