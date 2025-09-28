extends Node

enum Benefit {
	addchips,
	addmult,
	addmoney,
	xmult,
	chipnum,
	multnum,
	moneynum,
	num,
	creation,
	retrigger,
	copy,
	economy,
	hands,
	discards,
	to,
	arrow,
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
	probability,
	for_,
}

# duplication sucks but want a type matchup
enum Condition {
	none, to,
	face, joker,
	cards, discards, hands,
	spades, hearts, diamonds, clubs,
	zero, one, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace,
	highcard, pair, twopair, threeofakind, fullhouse, flush, straight, 
	straightflush, fourofakind, fiveofakind, flushhouse, flushfive,
	odd, even,
}

enum Rarity {
	common,
	uncommon,
	rare,
	legendary
}

enum Jokers {
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
	CreditCard,
	Banner,
	MysticSummit,
	EightBall,
	Misprint,
	RaisedFist,
	ChaosTheClown,
	ScaryFace,
	AbstractJoker,
	DelayedGratification,
	GrosMichel,
	EvenSteven,
	OddTodd,
	#Scholar,
	#BusinessCard,
	#Supernova
	#RideTheBus
	#Egg
	#Runner
	#IceCream
	#Splash
	#BlueJoker
	
	JokerStencil,

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

var jokers_by_rarity := {
	Rarity.common: [],
	Rarity.uncommon: [],
	Rarity.rare: [],
	Rarity.legendary: [],
}

func _ready():
	for id in joker_info.keys():
		var rarity = joker_info[id].rarity
		jokers_by_rarity[rarity].append(id)

# get info about joker (for descriptor and joker)
# score func on joker trigger
# trigger func on card trigger
var joker_info = {
	Jokers.Joker: {
		"name" : "Joker",
		"rarity" : Rarity.common,
		"score_func" : score_joker,
		"cost" : 2,
		"description" : "+4 Mult",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 4,
		"connective" : Connective.none,
	},
	Jokers.GreedyJoker: {
		"name" : "Greedy Joker",
		"rarity" : Rarity.common,
		"trigger_func" : trigger_greedy_joker,
		"cost" : 5,
		"description" : "Played cards with Diamond suit give +3 Mult when scored",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 3,
		"connective" : Connective.when_scored,
		"condition_0" : Condition.diamonds,
	},
	Jokers.LustyJoker: {
			"name" : "Lusty Joker",
			"rarity" : Rarity.common,
			"trigger_func" : trigger_lusty_joker,
			"cost" : 5,
			"description" : "Played cards with Heart suit give +3 Mult when scored",
			"benefit_0" : Benefit.addmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 3,
			"connective" : Connective.when_scored,
			"condition_0" : Condition.hearts,
	},
	Jokers.WrathfulJoker: {
			"name" : "Wrathful Joker",
			"rarity" : Rarity.common,
			"trigger_func" : trigger_wrathful_joker,
			"cost" : 5,
			"description" : "Played cards with Spade suit give +3 Mult when scored",
			"benefit_0" : Benefit.addmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 3,
			"connective" : Connective.when_scored,
			"condition_0" : Condition.spades,
	},
	Jokers.GluttonousJoker: {
		"name" : "Gluttonous Joker",
		"rarity" : Rarity.common,
		"trigger_func" : trigger_gluttonous_joker,
		"cost" : 5,
		"description" : "Played cards with Club suit give +3 Mult when scored",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 3,
		"connective" : Connective.when_scored,
		"condition_0" : Condition.clubs,
	},
	Jokers.JollyJoker: {
		"name" : "Jolly Joker",
		"rarity" : Rarity.common,
		"score_func" : score_jolly_joker,
		"cost" : 3,
		"description" :  "+8 Mult if played hand contains a Pair",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 8,
		"connective" : Connective.contains,
		"condition_0" : Condition.pair,
	},
	Jokers.ZanyJoker: {
			"name" : "Zany Joker",
			"rarity" : Rarity.common,
			"score_func" : score_zany_joker,
			"cost" : 4,
			"description" : "+12 Mult if played hand contains a Three of a Kind",
			"benefit_0" : Benefit.addmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 12,
			"connective" : Connective.contains,
			"condition_0" : Condition.threeofakind,
	},
	Jokers.MadJoker: {
			"name" : "Mad Joker",
			"rarity" : Rarity.common,
			"score_func" : score_mad_joker,
			"cost" : 4,
			"description" :  "+10 Mult if played hand contains Two Pair",
			"benefit_0" : Benefit.addmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 10,
			"connective" : Connective.contains,
			"condition_0" : Condition.twopair,
			
	},
	Jokers.CrazyJoker: {
			"name" : "Crazy Joker",
			"rarity" : Rarity.common,
			"cost" : 4,
			"description" : "+12 Mult if played hand contains Straight",
			"benefit_0" : Benefit.addmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 12,
			"connective" : Connective.contains,
			"condition_0" : Condition.straight,
	},
	Jokers.DrollJoker: {
			"name" : "Droll Joker",
			"rarity" : Rarity.common,
			"score_func" : score_droll_joker,
			"cost" : 4,
			"description" : "+10 Mult if played hand contains Flush",
			"benefit_0" : Benefit.addmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 10,
			"connective" : Connective.contains,
			"condition_0" : Condition.flush,
	},
	Jokers.SlyJoker: {
			"name" : "Sly Joker",
			"rarity" : Rarity.common,
			"score_func" : score_sly_joker,
			"cost" : 3,
			"description" : "+50 Chips if played hand contains a Pair",
			"benefit_0" : Benefit.addchips,
			"benefit_1" : Benefit.chipnum,
			"benefit_val_1" : 50,
			"connective" : Connective.contains,
			"condition_0" : Condition.pair,
	},
	Jokers.WilyJoker: {
			"name" : "Wily Joker",
			"rarity" : Rarity.common,
			"score_func" : score_joker,
			"cost" : 4,
			"description" : "+100 Chips if played hand contains a Three of a Kind",
			"benefit_0" : Benefit.addchips,
			"benefit_1" : Benefit.chipnum,
			"benefit_val_1" : 100,
			"connective" : Connective.contains,
			"condition_0" : Condition.threeofakind,
	},
	Jokers.CleverJoker: {
			"name" : "Clever Joker",
			"rarity" : Rarity.common,
			"score_func" : score_clever_joker,
			"cost" : 4,
			"description" : "+80 Chips if played hand contains a Two Pair",
			"benefit_0" : Benefit.addchips,
			"benefit_1" : Benefit.chipnum,
			"benefit_val_1" : 80,
			"connective" : Connective.contains,
			"condition_0" : Condition.twopair,
	},
	Jokers.DeviousJoker: {
			"name" : "Devious Joker",
			"rarity" : Rarity.common,
			"score_func" : score_devious_joker,
			"cost" : 4,
			"description" : "+100 Chips if played hand contains a Straight",
			"benefit_0" : Benefit.addchips,
			"benefit_1" : Benefit.chipnum,
			"benefit_val_1" : 100,
			"connective" : Connective.contains,
			"condition_0" : Condition.straight,
	},
	Jokers.CraftyJoker: {
		"name" : "Crafty Joker",
		"rarity" : Rarity.common,
		"score_func" : score_crafty_joker,
		"cost" : 4,
		"description" : "+80 Chips if played hand contains a Flush",
		"benefit_0" : Benefit.addchips,
		"benefit_1" : Benefit.chipnum,
		"benefit_val_1" : 80,
		"connective" : Connective.contains,
		"condition_0" : Condition.flush,
	},
	Jokers.HalfJoker: {
		"name" : "Half Joker",
		"rarity" : Rarity.common,
		"score_func" : score_half_joker,
		"cost" : 5,
		"description" : "+20 Mult if played hand contains 3 or fewer cards",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 20,
		"connective" : Connective.contains,
		"condition_0" : Condition.three,
		"condition_1" : Condition.to,
		"condition_2" : Condition.zero,
		"condition_3" : Condition.cards,
	},
	Jokers.CreditCard: {
		"name" : "Credit Card",
		"rarity" : Rarity.common,
		"cost" : 1,
		"description" : "Go up to -$20 in debt",
		"debt_potential" : 20,
		"benefit_0" : Benefit.addmoney,
		"benefit_1" : Benefit.moneynum,
		"benefit_val_1" : 20,
		"connective" : Connective.none
	},
	Jokers.Banner: {
			"name" : "Banner",
			"rarity" : Rarity.common,
			"score_func" : score_banner,
			"cost" : 5,
			"description" : "+30 Chips for each remaining discard",
			"benefit_0" : Benefit.addchips,
			"benefit_1" : Benefit.chipnum,
			"benefit_val_1" : 30,
			"connective" : Connective.contains,
			"condition_0" : Condition.discards, # TODO
	},
	Jokers.MysticSummit: {
			"name" : "Mystic Summit",
			"rarity" : Rarity.common,
			"score_func" : score_mystic_summit,
			"cost" : 5,
			"description" : "+15 Mult when 0 discards remaining",
			"benefit_0" : Benefit.addmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 15,
			"connective" : Connective.none,
			"condition_0" : Condition.zero,
			"condition_1" : Condition.discards, # TODO
	},
	Jokers.EightBall: { # TODO
		"name" : "8 Ball",
		"rarity" : Rarity.common,
		"trigger_func" : trigger_eight_ball,
		"cost" : 5,
		"description" : "1 in 4 chance for each played 8 
						to create a Tarot card when scored
						(Must have room)",
		"benefit_0" : Benefit.num,
		"benefit_val_0" : 8,
		"benefit_1": Benefit.arrow,
		"benefit_2" : Benefit.creation,
		"connective": Connective.none,
	},
	Jokers.Misprint: {
		"name" : "Misprint",
		"rarity" : Rarity.common,
		"score_func" : score_misprint,
		"cost" : 4,
		"description" : "+0-23 Mult",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 0,
		"benefit_2" : Benefit.to,
		"benefit_3" : Benefit.multnum,
		"benefit_val_3" : 23,
		"connective" : Connective.none,
	},
	Jokers.RaisedFist: {
		"name" : "Raised Fist",
		"rarity" : Rarity.common,
		"score_func" : score_raised_fist,
		"cost" : 5,
		"description" : "Adds double the rank of lowest ranked card held in hand to Mult",
		"benefit_0" : Benefit.addmult,
		"connective" : Connective.held_hand, # TODO
	},
	Jokers.ChaosTheClown: { # TODO
		"name" : "Chaos The Clown",
		"rarity" : Rarity.common,
		"free_roll": 1,
		"cost" : 4,
		"description" : "1 free Reroll per shop ",
		"connective" : Connective.none,
	},
	Jokers.ScaryFace: {
		"name" : "Scary Face",
		"rarity" : Rarity.common,
		"trigger_func" : trigger_scary_face,
		"cost" : 4,
		"description" : "Played face cards give +30 Chips when scored",
		"benefit_0" : Benefit.addchips,
		"benefit_1" : Benefit.chipnum,
		"benefit_val_1" : 30,
		"connective" : Connective.when_scored,
		"condition_0" : Condition.face,
	},
	Jokers.AbstractJoker: {
		"name" : "Abstract Joker",
		"rarity" : Rarity.common,
		"score_func" : score_abstract_joker,
		"cost" : 4,
		"description" : "+3 Mult for each Joker card",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : -1, # is a variable
		"connective" : Connective.for_,
		"condition_0" : Condition.joker,
	},
	Jokers.DelayedGratification: { # TODO
		"name" : "Delayed Gratification",
		"rarity" : Rarity.common,
		"cost" : 4,
		"description" : "Earn  $2 per discard if no discards
						are used by the end of the round",
		"benefit_0" : Benefit.addmoney,
		"benefit_1" : Benefit.moneynum,
		"benefit_val_1" : 2,
		"connective" : Connective.for_,
		"condition_0" : Condition.zero,
		"condition_1" : Condition.discards,
	},
	Jokers.GrosMichel: {
		"name" : "Gros Michel",
		"rarity" : Rarity.common,
		"score_func" : score_gros_michel,
		"round_end_func" : round_end_gros_michel,
		"cost" : 5,
		"description" : "+15 Mult. 1 in 6 chance this is destroyed
						at the end of the round",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 15,
		"connective" : Connective.none,
	},
	Jokers.EvenSteven: {
		"name" : "Even Steven",
		"rarity" : Rarity.common,
		"trigger_func" : trigger_even_steven,
		"cost" : 4,
		"description" : "Played cards with even rank give +4
						Mult when scored (10, 8, 6, 4, 2)",
		"benefit_0" : Benefit.addmult,
		"benefit_1" : Benefit.multnum,
		"benefit_val_1" : 4,
		"connective" : Connective.is_,
		"condition_0" : Condition.even, # TODO
	},
	Jokers.OddTodd: {
		"name" : "Odd Todd",
		"rarity" : Rarity.common,
		"trigger_func" : trigger_odd_todd,
		"cost" : 4,
		"description" : "Played cards with and odd rank give +31
						Chips when scored (A, 9, 7, 5, 3)",
		"benefit_0" : Benefit.addchips,
		"benefit_1" : Benefit.chipnum,
		"benefit_val_1" : 31,
		"connective" : Connective.is_,
		"condition_0" : Condition.odd, # TODO
	},
	
	# UNCOMMON JOKERS
	Jokers.JokerStencil: {
			"name" : "Joker Stencil",
			"rarity" : Rarity.uncommon,
			"score_func" : score_joker_stencil,
			"cost" : 8,
			"description" : "X1 Mult for each empty Joker slot. Joker Stencil included",
			"benefit_0" : Benefit.xmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : -1, # variable
			"connective" : Connective.for_,
			"condition_0" : Condition.joker,
	},
	
	# RARE JOKERS
	Jokers.TheDuo: {
			"name" : "The Duo",
			"rarity" : Rarity.rare,
			"score_func" : score_the_duo,
			"cost" : 8,
			"description" : "X2 Mult if played hand contains a Pair",
			"benefit_0" : Benefit.xmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 2,
			"connective" : Connective.contains,
			"condition_0" : Condition.pair,
	},
	Jokers.TheTrio: {
			"name" : "The Trio",
			"rarity" : Rarity.rare,
			"score_func" : score_the_trio,
			"cost" : 8,
			"description" : "X3 Mult if played hand contains a Three of a Kind",
			"benefit_0" : Benefit.xmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 3,
			"connective" : Connective.contains,
			"condition_0" : Condition.threeofakind,
	},
	Jokers.TheFamily: {
			"name" : "The Family",
			"rarity" : Rarity.rare,
			"score_func" : score_the_family,
			"cost" : 8,
			"description" : "X4 Mult if played hand contains a Four of a Kind",
			"benefit_0" : Benefit.xmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 4,
			"connective" : Connective.contains,
			"condition_0" : Condition.fourofakind,
	},
	Jokers.TheOrder: {
			"name" : "The Order",
			"rarity" : Rarity.rare,
			"score_func" : score_the_order,
			"cost" : 8,
			"description" : "X3 Mult if played hand contains a Straight",
			"benefit_0" : Benefit.xmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 3,
			"connective" : Connective.contains,
			"condition_0" : Condition.straight,
	},
	Jokers.TheTribe: {
			"name" : "The Tribe",
			"rarity" : Rarity.rare,
			"score_func" : score_the_tribe,
			"cost" : 8,
			"description" : "X2 Mult if played hand contains a Flush",
			"benefit_0" : Benefit.xmult,
			"benefit_1" : Benefit.multnum,
			"benefit_val_1" : 2,
			"connective" : Connective.contains,
			"condition_0" : Condition.flush,
	}
}

# always pass in card data and gamestate

# common jokers
func score_joker(_joker, _gamestate) -> Dictionary:
	return {"mult": 4}
func score_jolly_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_pair(gamestate.active_cards)):
		return {"mult": 8}
	return {}
func score_zany_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_three_of_a_kind(gamestate.active_cards)):
		return {"mult": 12}
	return {}
func score_mad_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_two_pair(gamestate.active_cards)):
		return {"mult": 10}
	return {}
func score_crazy_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_straight(gamestate.active_cards)):
		return {"mult": 12}
	return {}
func score_droll_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_flush(gamestate.active_cards)):
		return {"mult": 10}
	return {}
func score_sly_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_pair(gamestate.active_cards)):
		return {"chips": 50}
	return {}
func score_wily_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_three_of_a_kind(gamestate.active_cards)):
		return {"chips": 100}
	return {}
func score_clever_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_two_pair(gamestate.active_cards)):
		return {"chips": 80}
	return {}
func score_devious_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_straight(gamestate.active_cards)):
		return {"chips": 100}
	return {}
func score_crafty_joker(_joker, gamestate) -> Dictionary:
	if (CardManager.is_flush(gamestate.active_cards)):
		return {"chips": 80}
	return {}
func score_half_joker(_joker, gamestate) -> Dictionary:
	if (gamestate.played_cards.size() <= 3):
		return {"mult": 20}
	return {}
func score_banner(_joker, gamestate) -> Dictionary:
	if (gamestate.discards > 0):
		return {"chips": 30*gamestate.discards}
	return {}
func score_mystic_summit(_joker, gamestate) -> Dictionary:
	if (gamestate.discards == 0):
		return {"mult": 15}
	return {}
func score_misprint(_joker, _gamestate) -> Dictionary:
	var val = CardData.get_rnd_int(0, 23)
	if (val == 0):
		return {}
	return {"mult": val}
func score_raised_fist(_joker, gamestate) -> Dictionary:
	var hand = gamestate.held_cards
	if (hand.size() == 0):
		return {}
	
	var min_rank = INF
	for i in range(hand.size()):
		if hand[i] == null:
			continue
		
		if hand[i].get_rank() < min_rank:
			min_rank = hand[i].get_rank()
	
	return {"mult": 2 * min_rank}
func score_abstract_joker(_joker, gamestate) -> Dictionary:
	if (gamestate.jokers.size() > 0):
		return {"mult": gamestate.jokers.size() * 3, "eq_variable": gamestate.jokers.size() * 3}
	return {}
func score_gros_michel(_joker, _gamestate) -> Dictionary:
	return {"mult": 15}

# uncommon jokers
func score_joker_stencil(_joker, gamestate) -> Dictionary: # needs joker size and joker count
	# joker stencil
	var empty_slots = gamestate.max_jokers - gamestate.jokers.size()
	for j in gamestate.jokers:
		if (j.get_id() == JokerManager.Jokers.JokerStencil):
			empty_slots += 1
	
	if (empty_slots > 0):
		return {"xmult": empty_slots, "eq_variable": empty_slots}
	return {}

# rare jokers
func score_the_duo(_joker: JokerCardData, gamestate: Dictionary) -> Dictionary:
	if (CardManager.is_pair(gamestate.active_cards)):
		return {"xmult": 2}
	return {}
func score_the_trio(_joker: JokerCardData, gamestate: Dictionary) -> Dictionary:
	if (CardManager.is_three_of_a_kind(gamestate.active_cards)):
		return {"xmult": 3}
	return {}
func score_the_family(_joker: JokerCardData, gamestate: Dictionary) -> Dictionary:
	if (CardManager.is_four_of_a_kind(gamestate.active_cards)):
		return {"xmult": 4}
	return {}
func score_the_order(_joker: JokerCardData, gamestate: Dictionary) -> Dictionary:
	if (CardManager.is_straight(gamestate.active_cards)):
		return {"xmult": 3}
	return {}
func score_the_tribe(_joker: JokerCardData, gamestate: Dictionary) -> Dictionary:
	if (CardManager.is_flush(gamestate.active_cards)):
		return {"xmult": 2}
	return {}
	

func trigger_greedy_joker(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (card.suit == CardManager.Suit.diamonds
	or card.is_wild_card()):
		return {"mult": 3}
	return {}
func trigger_lusty_joker(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (card.suit == CardManager.Suit.hearts
	or card.is_wild_card()):
		return {"mult": 3}
	return {}
func trigger_wrathful_joker(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (card.suit == CardManager.Suit.spades
	or card.is_wild_card()):
		return {"mult": 3}
	return {}
func trigger_gluttonous_joker(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (card.suit == CardManager.Suit.clubs
	or card.is_wild_card()):
		return {"mult": 3}
	return {}
func trigger_eight_ball(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (card.rank == 8):
		if (JokerCardData.do_dice_roll(1, 4)):
			return {"create": ConsumableCardData.ConsumableType.tarot}
	return {}
func trigger_scary_face(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (CardManager.is_facecard(card.rank)):
		return {"chips": 30}
	return {}
func trigger_even_steven(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (CardManager.is_even(card.rank)):
		return {"mult": 4}
	return {}
func trigger_odd_todd(_joker: JokerCardData, card: CardData) -> Dictionary:
	if (CardManager.is_odd(card.rank)):
		return {"chips": 31}
	return {}


func round_end_gros_michel(_joker: JokerCardData):
	# 1 in 6 chance self destruct
	if (JokerCardData.do_dice_roll(1, 6)):
		# destruct
		return {"self_destruct" : true}
	return {}


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
