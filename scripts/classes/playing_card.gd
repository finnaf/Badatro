class_name PlayingCardData
extends CardData

var rank: int
var suit: CardManager.Suit
var enhancement: CardManager.Enhancement
var seal: CardManager.Seal

var is_raised: bool = false
var is_flipped: bool = false

func _init(i: int, r: int, s: CardManager.Suit):
	id = i
	rank = r
	suit = s

# returns value of enhancement chips, mult, xmult, money
func get_enhancement_val() -> Dictionary:
	match enhancement:
		CardManager.Enhancement.bonus:
			return {"chips": 30}
		CardManager.Enhancement.mult:
			return {"mult": 4}
		CardManager.Enhancement.glass:
			return {"xmult": 2}
		CardManager.Enhancement.stone:
			return {"chips": 50}
		CardManager.Enhancement.lucky:
			# TODO: Lucky enhancement effects
			return {"mult": 20, "money": 20}
	return {}

func get_cost(discount_percent: float) -> int:		
	var cost = 1
	cost += get_edition_cost()
			
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_card() -> bool:
	return true
