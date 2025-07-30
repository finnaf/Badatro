extends Node2D

@onready var WinUI = $Mat/MoneyCountUI
@onready var BottomButtons = $"Mat/BottomButtons"
@onready var sidebar = $Mat/Sidebar
@onready var shop = $"Shop"
@onready var deck = $Deck

var seed = 3

const GAMESPEED = 0.2
const INCRSPEED = GAMESPEED / 7
const MAXSPEED = 0.05
var gamespeed

const BASEHANDSIZE = 8

const BASEDECKSIZE = 52
var decksize = 52

var ante = 1
var round = 1
var blind = 0 # 0, 1 or 2

var voucher_count = 1

const BASE_REROLL_COST = 5
var reroll_cost = 5

var money = 99

const BASEHANDS = 4
const BASEDISCARDS = 3
var hands = 4
var discards = 3

var score = 0
var state = states.PLAYING

enum states {
	PLAYING,
	WAITING, # animations
	WINNING,
	SHOPPING,
	SETTINGS
}

var chips = 0
var mult = 0

var hand = "none"

var levels = {
	"none": 0,
	"flush five": 0,
	"flush house": 0,
	"five of a kind": 0,
	"straight flush": 0,
	"four of a kind": 0,
	"full house": 0,
	"flush": 0,
	"straight": 0,
	"three of a kind": 0,
	"two pair": 0,
	"pair": 0,
	"high card": 0
}

var hands_played = {
	"none": 0,
	"flush five": 0,
	"flush house": 0,
	"five of a kind": 0,
	"straight flush": 0,
	"four of a kind": 0,
	"full house": 0,
	"flush": 0,
	"straight": 0,
	"three of a kind": 0,
	"two pair": 0,
	"pair": 0,
	"high card": 0
}

signal updateMoneyUI
signal updateScoreUI
signal updateGoalUI
signal updateCashoutUI

func _ready():
	updateGoalUI.emit()
	setup(2)

func setup(game_seed: int):
	seed = game_seed
	seed(seed) # for shuffling cards
	JokerManager.new_game(seed) # for drawing jokers
	
	gamespeed = GAMESPEED
	
	deck.setup()
	deck.begin_round()

func is_win():
	if state == states.WINNING:
		return 1
	
func calculate_goal():
	return BossManager.get_chip_req(ante, blind)


func get_seed():
	return seed
	
# for the increasing speed of cards
func get_speed():
	gamespeed = lerp(gamespeed, MAXSPEED, INCRSPEED)
	#print(gamespeed)
	return gamespeed

func get_base_speed():
	return GAMESPEED

func get_deck_size():
	return decksize

func get_hand_size():
	var hand_size = BASEHANDSIZE
	return hand_size

func get_discount_percent():
	# clearance sale = 0.75
	# liquidation = 0.5
	return 1

func get_money_gained():
	if blind == 0:
		return 3
	elif blind == 1:
		return 4
	else:
		if ante % 8 == 0:
			return 8
		return 5

func get_reroll_cost():
	return reroll_cost

func get_round():
	return round

func get_ante():
	return ante
	
func get_basic_deck() -> Array:
	var ranks = range(2, 15) #2-15
	var deck = []
	var count = 0
		
	for suit_name in CardManager.Suit:
		var suit_val = CardManager.Suit[suit_name]
		for rank in ranks:
			var card = {
				"id": count,
				"type": CardManager.CardType.card,
				"suit": suit_val,
				"rank": rank,
				"raised": false,
				"enhancement": CardManager.Enhancement.none,
				"edition": CardManager.Edition.none,
				"seal": CardManager.Seal.none
			}
			
			deck.append(card)
			count += 1
	return deck

# returns all values needed to evaluate jokers
func get_game_state() -> Dictionary:
	return {
		"current_hand": hand,
		"hands": hands,
		"discards": discards,
	}

func set_hand(new_hand: String):
	hand = new_hand
	chips = CardManager.base_values[hand][0] + (levels[hand] * CardManager.planet_values[hand][0])
	mult = CardManager.base_values[hand][1] + (levels[hand] * CardManager.planet_values[hand][1])

func can_discard():
	if discards <= 0 or state != states.PLAYING:
		return false
	return true

func discard():
	discards -= 1

func play(cards: Array):
	state = states.WAITING
	hands_played[hand] += 1
	hands -= 1

func process_reroll():
	reroll_cost += 1

func is_voucher():
	if voucher_count > 0:
		return true
	return false

# returns false if doesn't succeed
func spend_money(cost: int) -> bool:
	if (money >= cost):
		money -= cost
		updateMoneyUI.emit()
		shop.update_buy_labels()
		return true
	else:
		return false

func add_money(value: int):
	money += value
	sidebar.update_money()

func add_chips(value: int):
	chips += value
	sidebar.update_chips()

func add_mult(value: int):
	mult += value
	sidebar.update_mult()

func mult_mult(value: float):
	mult *= value
	sidebar.update_mult()

func end_turn():
	score += chips * mult
	updateScoreUI.emit()
	chips = 0
	mult = 0
	
	gamespeed = GAMESPEED
	
	# check win
	var req = BossManager.get_chip_req(ante, blind)
	if score >= req:
		state = states.WINNING
		
		updateCashoutUI.emit(req)
		
		BottomButtons.visible = false
		WinUI.visible = true
	
	else:
		state = states.PLAYING

func reset_score():
	hands = BASEHANDS
	discards = BASEDISCARDS
	score = 0
	updateScoreUI.emit()

func cashout():
	add_money(get_money_gained() + (hands * 2))
	
	WinUI.visible = false
	reset_score()
	reroll_cost = BASE_REROLL_COST
	update_blind()
	sidebar.update_ante()
	shop.open()
	state = states.SHOPPING

func update_blind():
	blind += 1
	if blind > 2:
		voucher_count = 1
		blind = 0
		ante += 1

func next_round():
	shop.close()
	
	# TODO add choosing blinds
	
	round += 1
	sidebar.update_round()
	state = states.PLAYING
	BottomButtons.visible = true
	updateGoalUI.emit()

func add_resources(card, dict: Dictionary):
	# jokers have the value shown below, cards above
	var offset = 0
	if (card.data.type == CardManager.CardType.joker):
		offset = 24
	
	var alert = null
	for key in dict:
		if key == "chips":
			alert = Globals.do_score_alert(card, true, 
				true, dict.chips, GAMESPEED, offset)
			await add_chips(dict.chips)
		elif key == "mult":
			alert = Globals.do_score_alert(card, true, 
				false, dict.mult, GAMESPEED, offset)
			await add_mult(dict.mult)
		elif key == "xmult":
			alert = Globals.do_score_alert(card, false, 
				false, dict.xmult, GAMESPEED, offset)
			await add_chips(dict.xmult)
		elif key == "money":
			alert = Globals.do_score_alert(card, true, 
				true, dict.money, GAMESPEED, offset)
			await add_money(dict.money)
		else:
			continue
		
		# display
		await get_tree().create_timer(get_speed()).timeout
		
		# delete
		if (alert):
			alert.queue_free()
			await get_tree().create_timer(abs(get_speed() - 0.1) / 3).timeout	
