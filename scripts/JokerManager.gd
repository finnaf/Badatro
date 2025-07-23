extends Node

enum Benefit {
	achips,
	amult,
	xmult,
	achipsmult,
	creation,
	retrigger,
	copy,
	economy,
	hands,
	discards,
	other
}

# description connective
enum Connective {
	none, # totally empty second row
	when_scored,
	contains,
	on_discard,
	held_hand,
	blind_selected,
	countdown,
	final_hand,
	probability
}

enum Rarity {
	common,
	uncommon,
	rare,
	legendary
}

enum Jokers {
	Joker,			# fully implemented
	GreedyJoker,
	LustyJoker,
	WrathfulJoker,
	GluttonousJoker,
	JollyJoker,
	ZanyJoker,
	MadJoker,
	CrazyJoker,
	DrollJoker,
	#SlyJoker,
	#WilyJoker,
	#CleverJoker,
	#DeviousJoker,
	#CraftyJoker,
	#HalfJoker,
	#JokerStencil,
	#FourFingers,
	#Mime,
	#CreditCard,
}

var rng_joker = RandomNumberGenerator.new()
var rng_edition = RandomNumberGenerator.new()

func new_game(seed: int):
	rng_joker.seed = seed
	rng_edition.seed = seed + 1

func get_rarity_string(rarity: Rarity) -> String:
	match rarity:
		Rarity.common:
			return "Common"
		Rarity.uncommon:
			return "Uncommon"
		Rarity.rare:
			return "Rare"
		Rarity.legendary:
			return "Legendary"
		_:
			return "Error"

func get_edition(rate: int, no_neg: bool) -> CardManager.Edition:
	var poll = rng_edition.randf()
	rate = 1
	
	# rate 1 = normal prob
	# rate 25 = guaranteed
	# rate 2 = hone
	# rate 4 = glow up
	
	# doesnt perfectly match, but pretty close
	if (poll > 1 - (0.003 * rate) and not no_neg):
		return CardManager.Edition.negative
	elif (poll > 1 - 0.006 * rate):
		return CardManager.Edition.polychrome
	elif (poll > 1 - 0.02 * rate):
		return CardManager.Edition.holographic
	elif (poll > 1 - 0.04 * rate):
		return CardManager.Edition.foil
	else:
		return CardManager.Edition.none

# gets the next joker in the pool with normal edition dist
# NO NEGATIVES AS NOT IMPLEMENTED TODO
func generate_joker_data() -> Dictionary:
	var joker: Jokers = rng_joker.randi_range(0, Jokers.size()-1)
	
	var edition = get_edition(1, true)
	
	var data = {
		"id": joker,
		"type": CardManager.CardType.joker,
		"edition": edition,
	}
	
	return data

func get_joker_shortname(value: int) -> String:
	for joker in Jokers:
		if Jokers[joker] == value:
			return joker
	return "none"



func get_joker(joker: Jokers) -> Dictionary:
	match joker:
		Jokers.Joker:
			return {
				"name" : "Joker",
				"rarity" : Rarity.common,
				"cost" : 2,
				"description" : "+4 Mult",
				"benefit" : Benefit.amult,
				"benefit_val" : 4,
				"connective" : Connective.none
			}
		Jokers.GreedyJoker:#
			return {
				"name" : "Greedy Joker",
				"rarity" : Rarity.common,
				"cost" : 5,
				"description" : "Played cards with Diamond suit give +3 Mult when scored",
				"benefit" : Benefit.amult,
				"benefit_val" : 3,
				"connective" : Connective.when_scored,
				"condition" : CardManager.Suit.diamonds
			}
		Jokers.LustyJoker:
			return {
				"name" : "Lusty Joker",
				"rarity" : Rarity.common,
				"cost" : 5,
				"description" : "Played cards with Heart suit give +3 Mult when scored",
				"benefit" : Benefit.amult,
				"benefit_val" : 3,
				"connective" : Connective.when_scored,
				"condition" : CardManager.Suit.hearts,
			}
		Jokers.WrathfulJoker:
			return {
				"name" : "Wrathful Joker",
				"rarity" : Rarity.common,
				"cost" : 5,
				"description" : "Played cards with Spade suit give +3 Mult when scored",
				"benefit" : Benefit.amult,
				"benefit_val" : 3,
				"connective" : Connective.when_scored,
				"condition" : CardManager.Suit.spades,
			}
		Jokers.GluttonousJoker:
			return {
				"name" : "Gluttonous Joker",
				"rarity" : Rarity.common,
				"cost" : 5,
				"description" : "Played cards with Club suit give +3 Mult when scored",
				"benefit" : Benefit.amult,
				"benefit_val" : 3,
				"connective" : Connective.when_scored,
				"condition" : CardManager.Suit.clubs,
			}
		Jokers.JollyJoker:
			return {
				"name" : "Jolly Joker",
				"rarity" : Rarity.common,
				"cost" : 3,
				"description" :  "+8 Mult if played hand contains a Pair",
				"benefit" : Benefit.amult,
				"benefit_val" : 8777,
				"connective" : Connective.contains
			}
		Jokers.ZanyJoker:
			return {
				"name" : "Zany Joker",
				"rarity" : Rarity.common,
				"cost" : 4,
				"description" : "+12 Mult if played hand contains a Three of a Kind",
				"benefit" : Benefit.amult,
				"benefit_val" : 12,
				"connective" : Connective.contains
			}
		Jokers.MadJoker:
			return {
				"name" : "Mad Joker",
				"rarity" : Rarity.common,
				"cost" : 4,
				"description" :  "+10 Mult if played hand contains Two Pair",
				"benefit" : Benefit.amult,
				"benefit_val" : 1077,
				"connective" : Connective.contains
			}
		Jokers.CrazyJoker:
			return {
				"name" : "Crazy Joker",
				"rarity" : Rarity.common,
				"cost" : 4,
				"description" : "+12 Mult if played hand contains Straight",
				"benefit" : Benefit.amult,
				"benefit_val" : 1207,
				"connective" : Connective.contains
			}
		Jokers.DrollJoker:
			return {
				"name" : "Droll Joker",
				"rarity" : Rarity.common,
				"cost" : 4,
				"description" : "+10 Mult if played hand contains Flush",
				"benefit" : Benefit.amult,
				"benefit_val" : 1077,
				"connective" : Connective.contains
			}
	return {}
			
# gets the value of the joker when its triggered
# [chips, mult, xmult, money]
func get_score_val(active_cards: Array, joker, state: Dictionary) -> Dictionary:
	match joker.data.id:
		Jokers.Joker:
			return {"mult": 4}
		Jokers.JollyJoker:
			return score_jolly_joker(active_cards)
		Jokers.ZanyJoker:
			return score_zany_joker(active_cards)
		Jokers.MadJoker:
			return score_mad_joker(active_cards)
		Jokers.CrazyJoker:
			return score_crazy_joker(active_cards)
		Jokers.DrollJoker:
			return score_droll_joker(active_cards)
		_:
			return {}

func score_jolly_joker(cards) -> Dictionary:
	if (CardManager.is_pair(cards)):
		return {"mult": 8}
	return {}
func score_zany_joker(cards) -> Dictionary:
	if (CardManager.is_three_of_a_kind(cards)):
		return {"mult": 12}
	return {}
func score_mad_joker(cards) -> Dictionary:
	if (CardManager.is_two_pair(cards)):
		return {"mult": 10}
	return {}
func score_crazy_joker(cards) -> Dictionary:
	if (CardManager.is_straight(cards)):
		return {"mult": 12}
	return {}
func score_droll_joker(cards) -> Dictionary:
	if (CardManager.is_flush(cards)):
		return {"mult": 10}
	return {}

# gets the value of the joker from a specific card being triggered
# chips, mult, xmult, money
func get_trigger_val(card, joker) -> Dictionary:
	match joker.data.id:
		Jokers.GreedyJoker:
			return trigger_greedy_joker(card.data)
		Jokers.LustyJoker:
			return trigger_lusty_joker(card.data)
		Jokers.WrathfulJoker:
			return trigger_wrathful_joker(card.data)
		Jokers.GluttonousJoker:
			return trigger_gluttonous_joker(card.data)
		_:
			return {}
		
	# score on suit
	# score on rank
	# score on face cards

func trigger_greedy_joker(card: Dictionary) -> Dictionary:
	if (card.suit == CardManager.Suit.diamonds):
		return {"mult": 3}
	return {}
func trigger_lusty_joker(card: Dictionary) -> Dictionary:
	if (card.suit == CardManager.Suit.hearts):
		return {"mult": 3}
	return {}
func trigger_wrathful_joker(card: Dictionary) -> Dictionary:
	if (card.suit == CardManager.Suit.spades):
		return {"mult": 3}
	return {}
func trigger_gluttonous_joker(card: Dictionary) -> Dictionary:
	if (card.suit == CardManager.Suit.clubs):
		return {"mult": 3}
	return {}
