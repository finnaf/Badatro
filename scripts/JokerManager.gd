extends Node

enum Benefit {
	addchips,
	addmult,
	xmult,
	chipnum,
	multnum,
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
	none,
	when_scored,
	contains,
	is_,
	on_discard,
	held_hand,
	blind_selected,
	countdown,
	final_hand,
	probability
}

# duplication sucks but want a type matchup
enum Condition {
	none, to,
	face,
	cards, discards, hands,
	spades, hearts, diamonds, clubs,
	zero, one, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace,
	highcard, pair, twopair, threeofakind, fullhouse, flush, straight, 
	straightflush, fourofakind, fiveofakind, flushhouse, flushfive,
}

enum Rarity {
	common,
	uncommon,
	rare,
	legendary
}

enum CommonJokers {
	Joker,
	GreedyJoker,
	LustyJoker,
	WrathfulJoker,
	GluttonousJoker,
	JollyJoker,
	ZanyJoker,
	MadJoker,
	CrazyJoker,
	DrollJoker,
	SlyJoker,
	WilyJoker,
	CleverJoker,
	DeviousJoker,
	CraftyJoker,
	HalfJoker,
	#CreditCard,
	Banner,
	MysticSummit,
	#8Ball,
	Misprint,
	RaisedFist,
}

enum UncommonJokers {
	JokerStencil,
}

enum RareJokers {
	#DNA,
	#Vagabond,
	#Baron,
	#Obelisk,
	#BaseballCard
	#AncientJoker,
	#Campfire,
	#Blueprint,
	#WeeJoker,
	#HitTheRoad,
	TheDuo,
	TheTrio,
	TheFamily,
	TheOrder,
	TheTribe,
	#Stuntman,
	#InvisibleJoker,
	#Brainstorm,
	#DriversLicense
	#BurntJoker
}

enum LegendaryJokers {
	
}

var rng_joker = RandomNumberGenerator.new()
var rng_edition = RandomNumberGenerator.new()
var rng = RandomNumberGenerator.new()			# within jokers

func new_game(seed: int):
	rng_joker.seed = seed + 1
	rng_edition.seed = seed + 2
	rng.seed = seed + 3

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
# 70 / 25 / 5
func generate_joker_data() -> Dictionary:
	var joker
	var rarity: Rarity
	var rarity_pick = rng_joker.randf()
	if (rarity_pick > 0.95):
		rarity = Rarity.rare
		joker = rng_joker.randi_range(0, RareJokers.size()-1)
	elif (rarity_pick > 0.7):
		rarity = Rarity.uncommon
		joker = rng_joker.randi_range(0, UncommonJokers.size()-1)
	else:
		rarity = Rarity.common
		joker = rng_joker.randi_range(0, CommonJokers.size()-1)

	var edition = get_edition(1, true)
	
	var data = {
		"id": joker,
		"rarity": rarity,
		"type": CardManager.CardType.joker,
		"edition": edition,
	}
	
	
	if (data.id == -1):
		data.id = 1
		data.rarity = Rarity.common
	
	return data

# convert id to enum string name
func get_joker_shortname(value: int, rarity: Rarity) -> String:
	match rarity:
		Rarity.common:
			for joker in CommonJokers:
				if CommonJokers[joker] == value:
					return joker
		Rarity.uncommon:
			for joker in UncommonJokers:
				if UncommonJokers[joker] == value:
					return joker
		Rarity.rare:
			for joker in RareJokers:
				if RareJokers[joker] == value:
					return joker
	return "none"

# get additional information about joker (mostly for descriptor, not scoring)
func get_joker(joker_id: int, rarity: Rarity) -> Dictionary:
	if (rarity == Rarity.common):
		match joker_id:
			CommonJokers.Joker:
				return {
					"name" : "Joker",
					"rarity" : Rarity.common,
					"cost" : 2,
					"description" : "+4 Mult",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 4,
					"connective" : Connective.none
				}
			CommonJokers.GreedyJoker:
				return {
					"name" : "Greedy Joker",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "Played cards with Diamond suit give +3 Mult when scored",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 3,
					"connective" : Connective.when_scored,
					"condition_0" : Condition.diamonds
				}
			CommonJokers.LustyJoker:
				return {
					"name" : "Lusty Joker",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "Played cards with Heart suit give +3 Mult when scored",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 3,
					"connective" : Connective.when_scored,
					"condition_0" : Condition.hearts,
				}
			CommonJokers.WrathfulJoker:
				return {
					"name" : "Wrathful Joker",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "Played cards with Spade suit give +3 Mult when scored",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 3,
					"connective" : Connective.when_scored,
					"condition_0" : Condition.spades,
				}
			CommonJokers.GluttonousJoker:
				return {
					"name" : "Gluttonous Joker",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "Played cards with Club suit give +3 Mult when scored",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 3,
					"connective" : Connective.when_scored,
					"condition_0" : Condition.clubs,
				}
			CommonJokers.JollyJoker:
				return {
					"name" : "Jolly Joker",
					"rarity" : Rarity.common,
					"cost" : 3,
					"description" :  "+8 Mult if played hand contains a Pair",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 8,
					"connective" : Connective.contains,
					"condition_0" : Condition.pair,
				}
			CommonJokers.ZanyJoker:
				return {
					"name" : "Zany Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+12 Mult if played hand contains a Three of a Kind",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 12,
					"connective" : Connective.contains,
					"condition_0" : Condition.threeofakind,
				}
			CommonJokers.MadJoker:
				return {
					"name" : "Mad Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" :  "+10 Mult if played hand contains Two Pair",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 10,
					"connective" : Connective.contains,
					"condition_0" : Condition.twopair,
					
				}
			CommonJokers.CrazyJoker:
				return {
					"name" : "Crazy Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+12 Mult if played hand contains Straight",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 12,
					"connective" : Connective.contains,
					"condition_0" : Condition.straight,
				}
			CommonJokers.DrollJoker:
				return {
					"name" : "Droll Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+10 Mult if played hand contains Flush",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 10,
					"connective" : Connective.contains,
					"condition_0" : Condition.flush,
				}
			CommonJokers.SlyJoker:
				return {
					"name" : "Sly Joker",
					"rarity" : Rarity.common,
					"cost" : 3,
					"description" : "+50 Chips if played hand contains a Pair",
					"benefit_0" : Benefit.addchips,
					"benefit_1" : Benefit.chipnum,
					"benefit_val_1" : 50,
					"connective" : Connective.contains,
					"condition_0" : Condition.pair,
				}
			CommonJokers.WilyJoker:
				return {
					"name" : "Wily Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+100 Chips if played hand contains a Three of a Kind",
					"benefit_0" : Benefit.addchips,
					"benefit_1" : Benefit.chipnum,
					"benefit_val_1" : 100,
					"connective" : Connective.contains,
					"condition_0" : Condition.threeofakind,
				}
			CommonJokers.CleverJoker:
				return {
					"name" : "Clever Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+80 Chips if played hand contains a Two Pair",
					"benefit_0" : Benefit.addchips,
					"benefit_1" : Benefit.chipnum,
					"benefit_val_1" : 80,
					"connective" : Connective.contains,
					"condition_0" : Condition.twopair,
				}
			CommonJokers.DeviousJoker:
				return {
					"name" : "Devious Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+100 Chips if played hand contains a Straight",
					"benefit_0" : Benefit.addchips,
					"benefit_1" : Benefit.chipnum,
					"benefit_val_1" : 100,
					"connective" : Connective.contains,
					"condition_0" : Condition.straight,
				}
			CommonJokers.CraftyJoker:
				return {
					"name" : "Crafty Joker",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+80 Chips if played hand contains a Flush",
					"benefit_0" : Benefit.addchips,
					"benefit_1" : Benefit.chipnum,
					"benefit_val_1" : 80,
					"connective" : Connective.contains,
					"condition_0" : Condition.flush,
				}
			CommonJokers.HalfJoker:
				return {
					"name" : "Half Joker",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "+20 Mult if played hand contains 3 or fewer cards",
					"benefit_0" : Benefit.addchips,
					"benefit_1" : Benefit.chipnum,
					"benefit_val_1" : 20,
					"connective" : Connective.contains,
					"condition_0" : Condition.three,
					"condition_1" : Condition.to,
					"condition_2" : Condition.zero,
					"condition_3" : Condition.cards,
				}
			CommonJokers.Banner:
				return {
					"name" : "Banner",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "+30 Chips for each remaining discard",
					"benefit_0" : Benefit.addchips,
					"benefit_1" : Benefit.chipnum,
					"benefit_val_1" : 30,
					"connective" : Connective.contains,
					"condition_0" : Condition.flush, # TODO
				}
			CommonJokers.MysticSummit:
				return {
					"name" : "Mystic Summit",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "+15 Mult when 0 discards remaining",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 15,
					"connective" : Connective.contains, # when -> 0D
					"condition_0" : Condition.flush, # TODO
				}
			CommonJokers.Misprint:
				return {
					"name" : "Misprint",
					"rarity" : Rarity.common,
					"cost" : 4,
					"description" : "+0-23 Mult",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 0,
					"connective" : Connective.none,
				}
			CommonJokers.RaisedFist: # TODO
				return {
					"name" : "Raised Fist",
					"rarity" : Rarity.common,
					"cost" : 5,
					"description" : "Adds double the rank of lowest ranked card held in hand to Mult",
					"benefit_0" : Benefit.addmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 0,
					"connective" : Connective.none,
				}
	if (rarity == Rarity.uncommon):
		match joker_id:
			UncommonJokers.JokerStencil:
				return {
					"name" : "Joker Stencil",
					"rarity" : Rarity.uncommon,
					"cost" : 8,
					"description" : "X1 Mult for each empty Joker slot. Joker Stencil included",
					"benefit_0" : Benefit.xmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 5,
					"connective" : Connective.none,
					#"condition" : Condition.flush,
				}
	elif (rarity == Rarity.rare):
		match joker_id:
			RareJokers.TheDuo:
				return {
					"name" : "The Duo",
					"rarity" : Rarity.rare,
					"cost" : 8,
					"description" : "X2 Mult if played hand contains a Pair",
					"benefit_0" : Benefit.xmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 2,
					"connective" : Connective.contains,
					"condition_0" : Condition.pair,
				}
			RareJokers.TheTrio:
				return {
					"name" : "The Trio",
					"rarity" : Rarity.rare,
					"cost" : 8,
					"description" : "X3 Mult if played hand contains a Three of a Kind",
					"benefit_0" : Benefit.xmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 3,
					"connective" : Connective.contains,
					"condition_0" : Condition.threeofakind,
				}
			RareJokers.TheFamily:
				return {
					"name" : "The Family",
					"rarity" : Rarity.rare,
					"cost" : 8,
					"description" : "X4 Mult if played hand contains a Four of a Kind",
					"benefit_0" : Benefit.xmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 4,
					"connective" : Connective.contains,
					"condition_0" : Condition.fourofakind,
				}
			RareJokers.TheOrder:
				return {
					"name" : "The Order",
					"rarity" : Rarity.rare,
					"cost" : 8,
					"description" : "X3 Mult if played hand contains a Straight",
					"benefit_0" : Benefit.xmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 3,
					"connective" : Connective.contains,
					"condition_0" : Condition.straight,
				}
			RareJokers.TheTribe:
				return {
					"name" : "The Tribe",
					"rarity" : Rarity.rare,
					"cost" : 8,
					"description" : "X2 Mult if played hand contains a Flush",
					"benefit_0" : Benefit.xmult,
					"benefit_1" : Benefit.multnum,
					"benefit_val_1" : 2,
					"connective" : Connective.contains,
					"condition_0" : Condition.flush,
				}
	return {
		"name" : "Joker",
		"rarity" : Rarity.common,
		"cost" : 2,
		"description" : "+4 Mult",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 4,
		"connective" : Connective.none
	}
			
# gets the value of the joker when its triggered
# [chips, mult, xmult, money]
func get_score_val(active_cards: Array, joker: Node, state: Dictionary) -> Dictionary:
	if (joker.get_rarity() == Rarity.common):
		match joker.data.id:
			CommonJokers.Joker:
				return {"mult": 4}
			CommonJokers.JollyJoker:
				return score_jolly_joker(active_cards)
			CommonJokers.ZanyJoker:
				return score_zany_joker(active_cards)
			CommonJokers.MadJoker:
				return score_mad_joker(active_cards)
			CommonJokers.CrazyJoker:
				return score_crazy_joker(active_cards)
			CommonJokers.DrollJoker:
				return score_droll_joker(active_cards)
			CommonJokers.SlyJoker:
				return score_sly_joker(active_cards)
			CommonJokers.WilyJoker:
				return score_wily_joker(active_cards)
			CommonJokers.CleverJoker:
				return score_clever_joker(active_cards)
			CommonJokers.DeviousJoker:
				return score_devious_joker(active_cards)
			CommonJokers.CraftyJoker:
				return score_crafty_joker(active_cards)
			CommonJokers.HalfJoker:
				return score_half_joker(state.played_cards.size())
			CommonJokers.Banner:
				return score_banner(state.discards)
			CommonJokers.MysticSummit:
				return score_mystic_summit(state.discards)
			CommonJokers.Misprint:
				return score_misprint()
			CommonJokers.RaisedFist:
				return score_raised_fist(state.held_cards)
	
	elif (joker.get_rarity() == Rarity.uncommon):
		match joker.data.id:
			UncommonJokers.JokerStencil:
				return score_stencil_joker(state.jokers, state.max_jokers)
	
	elif (joker.get_rarity() == Rarity.rare):
		match joker.data.id:
			RareJokers.TheDuo:
				return score_the_duo(active_cards)
			RareJokers.TheTrio:
				return score_the_trio(active_cards)
			RareJokers.TheFamily:
				return score_the_family(active_cards)
			RareJokers.TheOrder:
				return score_the_order(active_cards)
			RareJokers.TheTribe:
				return score_the_tribe(active_cards)
	
	return {}

# common jokers
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
func score_sly_joker(cards) -> Dictionary:
	if (CardManager.is_pair(cards)):
		return {"chips": 50}
	return {}
func score_wily_joker(cards) -> Dictionary:
	if (CardManager.is_three_of_a_kind(cards)):
		return {"chips": 100}
	return {}
func score_clever_joker(cards) -> Dictionary:
	if (CardManager.is_two_pair(cards)):
		return {"chips": 80}
	return {}
func score_devious_joker(cards) -> Dictionary:
	if (CardManager.is_straight(cards)):
		return {"chips": 100}
	return {}
func score_crafty_joker(cards) -> Dictionary:
	if (CardManager.is_flush(cards)):
		return {"chips": 80}
	return {}
func score_half_joker(size) -> Dictionary:
	if (size <= 3):
		return {"mult": 20}
	return {}
func score_banner(discards) -> Dictionary:
	if (discards > 0):
		return {"chips": 30*discards}
	return {}
func score_mystic_summit(discards) -> Dictionary:
	if (discards == 0):
		return {"mult": 15}
	return {}
func score_misprint() -> Dictionary:
	var val = rng.randi_range(0, 23)
	if (val == 0):
		return {}
	return {"mult": val}
func score_raised_fist(hand) -> Dictionary:
	if (hand.size() == 0):
		return {}
	
	hand.sort_custom(func(a, b):
		if a.is_empty() and not b.is_empty():
			return false
		elif b.is_empty() and not a.is_empty():
			return true
		elif a.is_empty() and b.is_empty():
			return false
		
		return a.rank > b.rank
	)
	
	return {"mult": hand[0].rank}

# uncommon jokers
func score_stencil_joker(jokers, max_jokers) -> Dictionary: # needs joker size and joker count
	# joker stencil
	var empty_slots = max_jokers - jokers.size()
	for joker in jokers:
		if (joker.get_id() == JokerManager.UncommonJokers.JokerStencil and
			joker.get_rarity() == JokerManager.Rarity.uncommon):
				empty_slots += 1
	
	if (empty_slots > 0):
		return {"xmult": empty_slots}
	return {}

# rare jokers
func score_the_duo(cards) -> Dictionary:
	if (CardManager.is_pair(cards)):
		return {"xmult": 2}
	return {}
func score_the_trio(cards) -> Dictionary:
	if (CardManager.is_three_of_a_kind(cards)):
		return {"xmult": 3}
	return {}
func score_the_family(cards) -> Dictionary:
	if (CardManager.is_four_of_a_kind(cards)):
		return {"xmult": 4}
	return {}
func score_the_order(cards) -> Dictionary:
	if (CardManager.is_straight(cards)):
		return {"xmult": 3}
	return {}
func score_the_tribe(cards) -> Dictionary:
	if (CardManager.is_flush(cards)):
		return {"xmult": 2}
	return {}
	

# gets the value of the joker from a specific card being triggered
# chips, mult, xmult, money
func get_trigger_val(card, joker) -> Dictionary:
	if (joker.get_rarity() == Rarity.common):
		match joker.get_id():
			CommonJokers.GreedyJoker:
				return trigger_greedy_joker(card.data)
			CommonJokers.LustyJoker:
				return trigger_lusty_joker(card.data)
			CommonJokers.WrathfulJoker:
				return trigger_wrathful_joker(card.data)
			CommonJokers.GluttonousJoker:
				return trigger_gluttonous_joker(card.data)

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
