extends Node2D

var deck = []
var hand = []
var cards_remaining = 0

var selected_cards = []

var hand_size
var is_rank_sort = true

signal updateClickUI
signal updateButtonsUI

@onready var game = $".."
@onready var jokers = $"../Mat/Jokers"

func _ready():
	setup()
	begin_round()

func setup():
	deck = game.get_basic_deck()
	shuffle()

func begin_round():
	hand_size = game.get_hand_size()
	create_hand()
	cards_remaining = game.get_deck_size()
	deal()
	sort_hand()
			
func deal():
	while 1:
		if deck.is_empty():
			setup_connection()
			return
		
		var data = deck.pop_back()
		const CARD = preload("res://scenes/card.tscn")
		var card = CARD.instantiate()
		
		for i in range(hand_size):
			if hand[i] == {}:
				hand[i] = data
				cards_remaining -= 1
				break

			elif i == hand_size-1:
				deck.push_back(data)
				setup_connection()
				return
		
		add_child(card)
		card.setup(data)

func _on_play_button_pressed():
	if selected_cards.is_empty() or game.is_win():
		return
	
	var active_cards = CardManager.get_active_cards(selected_cards, game.hand)
	active_cards = sort_passed_cards(active_cards)
	game.play(active_cards)

	await count_animation(game.GAMESPEED, active_cards)
	await score_animation(game.GAMESPEED, active_cards)
	await jokers.score_jokers(game.GAMESPEED, active_cards)
	
	await game.end_turn()
	
	if game.is_win():
		delete_hand()
	else:
		deal()
		sort_hand()

	updateButtonsUI.emit()
	updateClickUI.emit()

# does counting animation and discards selected cards
func count_animation(speed, active_cards):
	selected_cards = sort_passed_cards(selected_cards)
	
	# move cards up from hand
	for i in range(selected_cards.size()):
		var card = selected_cards[i]
		
		# remove from hand and reorder hand
		var index = get_hand_position(card.get_id())
		hand[index] = {}
		sort_hand()
		
		card.position.x = get_card_position(i, selected_cards.size())
		card.position.y -= 4
		card.z_index = i
		
	await get_tree().create_timer(speed).timeout
	for i in range(active_cards.size()-1, -1, -1):
		var card = active_cards[i]
		card.position.y -= 4
		
		await get_tree().create_timer(speed).timeout

func score_animation(speed, active_cards):
	# SCORE LOOP
	for i in range(1, active_cards.size()+1):
		
		var card = active_cards[active_cards.size()-i]
		
		# CHIPS
		var cardval = CardManager.convert_rank_to_chipvalue(card.get_rank())
		var alert = Globals.do_score_alert(card, true, true, cardval, speed, 0)
		await game.add_chips(cardval)
		
		
		updateClickUI.emit()
		await get_tree().create_timer(speed).timeout
		alert.queue_free()
		
		# ENHANCEMENTS
		var enhancevals = CardManager.get_enhancement_val(card)
		game.add_resource(card, enhancevals)
		
		# EDITIONS
		var editionvals = await CardManager.get_edition_val(card)
		game.add_resource(card, editionvals)
		
		# JOKER ON CARD
		var jokercardval = await jokers.score_card(card)
		#await get_tree().create_timer(speed).timeout
	
	await get_tree().create_timer(speed).timeout
	# free
	for card in selected_cards:
		card.queue_free()
	selected_cards.clear()
	
func sort_passed_cards(cards):
	if is_rank_sort:
		cards.sort_custom(func(a, b):
			return a["data"]["suit"] < b["data"]["suit"]
		)
	
		cards.sort_custom(func(a, b):
			return a["data"]["rank"] < b["data"]["rank"]
		)
	else:
		cards.sort_custom(func(a, b):
			return a["data"]["rank"] < b["data"]["rank"]
		)
		cards.sort_custom(func(a, b):
			return a["data"]["suit"] < b["data"]["suit"]
		)
	return cards

func _on_discard_button_pressed():
	if not game.can_discard() or selected_cards.is_empty():
		return
	game.discard()
	
	for card in get_children():
		if card.has_method("is_raised") and card.has_method("get_data"):
			if card.is_raised():
				var index = get_hand_position(card.get_id())
				hand[index] = {}
				selected_cards.erase(card)
				card.queue_free()
	deal()
	sort_hand()
	updateButtonsUI.emit()
	
func _on_card_clicked(card):
	if (card in selected_cards):
		selected_cards.erase(card)
		card.deselect()
	elif selected_cards.size() < 5:
		selected_cards.append(card)
		card.select()
	
	game.set_hand(CardManager.calculate_hand(selected_cards))
	updateClickUI.emit()

func create_hand():
	for i in range(hand_size):
		hand.append({})

func clear_hand():
	for i in range(hand_size):
		hand[i] = {}

func delete_hand():
	for card in get_children():
		if card.has_method("get_data"):
			card.queue_free()
	clear_hand()

func shuffle():
	deck.shuffle()

func get_hand_position(card_id):
	for i in range(hand_size):
		if hand[i] == {}:
			continue
		if hand[i].id == card_id:
			return i
	return -1

func sort_hand():
	if is_rank_sort:
		sort_suit()
		sort_rank()
	else:
		sort_rank()
		sort_suit()

func sort_rank():	
	hand.sort_custom(func(a, b):
		if a.is_empty() and not b.is_empty():
			return false
		elif b.is_empty() and not a.is_empty():
			return true
		elif a.is_empty() and b.is_empty():
			return false
		
		return a["rank"] < b["rank"]
	)
	
	for card in get_children():
		if card.has_method("get_id"):
			
			for i in range(hand_size):
				if hand[i] == {}:
					continue
				if card.get_id() == hand[i].id:
					card.position.x = get_card_position(i, count_cards_in_hand())
					card.z_index = i

func sort_suit():	
	hand.sort_custom(func(a, b):
		if a.is_empty() and not b.is_empty():
			return false
		elif b.is_empty() and not a.is_empty():
			return true
		elif a.is_empty() and b.is_empty():
			return false
		
		return a["suit"] < b["suit"]
	)
	
	for card in get_children():
		if card.has_method("get_id"):
			
			for i in range(hand_size):
				if hand[i] == {}:
					continue
				if card.get_id() == hand[i].id:
					card.position.x = get_card_position(i, count_cards_in_hand())
					card.z_index = i

func _on_sort_suit_button_pressed():
	is_rank_sort = false
	sort_hand()

func _on_sort_rank_button_pressed():
	is_rank_sort = true
	sort_hand()

func get_card_position(i, num_cards):
	var spacing = round((106-20-5)/num_cards)
	var total_width = (num_cards - 1) * spacing
	return -((i * spacing) - (total_width/2))
	
func count_cards_in_hand():
	var i = 0
	for card in hand:
		if card != {}:
			i += 1
	return i

func setup_connection():
	for card in get_children():
		card.connect("card_clicked", Callable(self, "_on_card_clicked"))


func _on_cash_out_button_pressed() -> void:
	await game.cashout()
	updateButtonsUI.emit()


func _on_next_round_button_pressed() -> void:
	await game.next_round()
	begin_round()
