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
	
	#enhancement = randi_range(0,8)
	enhancement = CardManager.Enhancement.glass

# returns value of enhancement chips, mult, xmult, money
func get_enhancement_score_val() -> Dictionary:
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
			var out = {}
			
			if (JokerManager.get_rnd_float() > 0.75):
				out["mult"] = 20
			if (JokerManager.get_rnd_float() > 0.95):
				out["money"] = 20
			
			return out
	return {}

func get_enhancement_held_val() -> Dictionary:
	match enhancement:
		CardManager.Enhancement.steel:
			return {"xmult": 1.5}
		CardManager.Enhancement.gold:
			return {"money": 3}
	return {}

func is_stone_card():
	if enhancement == CardManager.Enhancement.stone:
		return true
	return false
	
func is_wild_card():
	if enhancement == CardManager.Enhancement.wild:
		return true
	return false

func get_cost(discount_percent: float) -> int:		
	var cost = 1
	cost += get_edition_cost()
			
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_card() -> bool:
	return true
