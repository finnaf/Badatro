class_name PlayingCardData
extends CardData

var rank: int
var suit: CardManager.Suit
var enhancement: CardManager.Enhancement
var seal: CardManager.Seal

var is_raised: bool = false
var is_flipped: bool = false

var chance_glass_break = 0.25

func _init(i: int = -1, r: int = -1, s: CardManager.Suit = -1):
	if (i == -1 or r == -1 or s == -1):
		# generate data here
		# playing card id doesnt matter at all
		id = 1
		rank = get_rnd_int(2, 13)
		suit = CardManager.Suit.values()[get_rnd_int(0, 3)]
		enhancement = CardManager.Enhancement.values()[get_rnd_int(0, 8)]
		return
	
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
			
			if (get_rnd_float() > 0.80):
				out["mult"] = 20
			if (get_rnd_float() > 0.93333): # 0.93 333...
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

# glass cards
func check_break() -> bool:
	if (not is_glass_card()):
		return false
	
	if (get_rnd_float() < chance_glass_break):
		return true
	return false

func is_stone_card():
	if enhancement == CardManager.Enhancement.stone:
		return true
	return false
	
func is_wild_card():
	if enhancement == CardManager.Enhancement.wild:
		return true
	return false

func is_glass_card():
	if enhancement == CardManager.Enhancement.glass:
		return true
	return false
func get_cost(discount_percent: float) -> int:		
	var cost = 1
	cost += get_edition_cost()
			
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_playing_card() -> bool:
	return true
