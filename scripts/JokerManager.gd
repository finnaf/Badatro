extends Node

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
	#JollyJoker,
	#ZanyJoker,
	#MadJoker,
	#CrazyJoker,
	#DrollJoker,
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

# name
# rarity
# cost
# description
func get_joker(joker: Jokers):
	match joker:
		Jokers.Joker:
			return ["Joker", Rarity.common, 2, "+4 Mult"]
		Jokers.GreedyJoker:
			return ["Greedy Joker", Rarity.common, 5, "Played cards with Diamond suit give +3 Mult when scored"]
		Jokers.LustyJoker:
			return ["Lusty Joker", Rarity.common, 5, "Played cards with Heart suit give +3 Mult when scored"]
		Jokers.WrathfulJoker:
			return ["Wrathful Joker", Rarity.common, 5, "Played cards with Spade suit give +3 Mult when scored"]
		Jokers.GluttonousJoker:
			return ["Gluttonous Joker", Rarity.common, 5, "Played cards with Club suit give +3 Mult when scored"]

# gets the value of the joker from a specific card being triggered
# chips, mult, xmult, money
func get_trigger_val(card, joker) -> Dictionary:
	return {}
	
	# score on suit
	# score on rank
	# score on face cards
	# score on every card

# gets the value of the joker when its triggered
# [chips, mult, xmult, money]
func on_score(active_cards: Array, joker) -> Dictionary:
	match joker.data.id:
		Jokers.Joker:
			return {"mult": 4}
		_:
			return {}
	
	return {}

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
