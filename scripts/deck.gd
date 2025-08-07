extends Node2D

var fulldeck = []
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

func setup():
	fulldeck = game.get_basic_deck()

func begin_round():
	hand_size = game.get_hand_size()
	create_hand()
	deck = fulldeck.duplicate(true)
	shuffle()
	cards_remaining = game.get_deck_size()
	is_rank_sort = true
	deal()
	sort_hand()
			
func deal():
	while 1:
		if deck.is_empty():
			setup_connection()
			return
		
		var data = deck.pop_back()
		var card = preload("res://scenes/card.tscn").instantiate()
		
				
		for i in range(hand_size):
			if hand[i] == null:
				hand[i] = card
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
	# cards currently arrayed in the order they were selected, so:
	selected_cards = sort_by_position(selected_cards)
	var active_cards = CardManager.get_active_cards(selected_cards, game.hand)
	game.play(active_cards)

	await count_animation(active_cards)
	await score_animation(active_cards)
	await jokers.score_jokers(active_cards)
	await hand_animation()
	
	# free
	for card in selected_cards:
		card.queue_free()
	selected_cards.clear()
	
	await game.end_turn()
	
	if game.is_win():
		delete_hand()
	else:
		deal()
		sort_hand()

	updateButtonsUI.emit()
	updateClickUI.emit()

# does counting animation and discards selected cards
func count_animation(active_cards):	
	# move cards up from hand
	for i in range(selected_cards.size()):
		var card = selected_cards[i]
		
		# remove from hand and adjust
		var index = get_hand_position(card.get_id())
		hand[index] = null
		
		card.position.x = get_card_position(i, selected_cards.size())
		card.position.y -= 4
		card.z_index = i
		
	await get_tree().create_timer(game.get_speed()).timeout
	for i in range(active_cards.size()-1, -1, -1):
		var card = active_cards[i]
		card.position.y -= 4
		
		await get_tree().create_timer(game.get_speed()).timeout

func score_animation(active_cards):
	# SCORE LOOP
	for i in range(1, active_cards.size()+1):
		
		var card = active_cards[active_cards.size()-i]
		
		# CHIPS & ENHANCEMENTS
		var vals : Dictionary = card.data.get_enhancement_score_val()
		var chips = 0
		if (not card.data.is_stone_card()):
			chips = CardManager.convert_rank_to_chipvalue(card.get_rank())
			if (vals.has("chips")):
				vals.chips += chips
			else: # add a chips key
				vals["chips"] = chips
		await game.add_resources(card, vals)
		
		# EDITIONS
		var editionvals = card.data.get_edition_val()
		await game.add_resources(card, editionvals)
		
		# JOKER ON CARD
		var jokercardvals = await jokers.score_card(card)
		for cardvals in  jokercardvals:
			await game.add_resources(card, cardvals)
	
	await get_tree().create_timer(game.get_speed()).timeout

func hand_animation():
	for i in range(hand.size()):
		var card = hand[hand.size()-1-i]
		if (card):
			await game.add_resources(card, 
				card.data.get_enhancement_held_val())

func sort_by_position(array) -> Array:
	array.sort_custom(func(a, b):
		return a.position.x > b.position.x
	)
	return array
	
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
				hand[index] = null
				selected_cards.erase(card)
				card.queue_free()
	deal()
	sort_hand()
	updateButtonsUI.emit()
	
func _on_card_clicked(card):
	if (game.state != game.states.PLAYING):
		return
	
	if (card in selected_cards):
		selected_cards.erase(card)
		card.deselect()
	elif selected_cards.size() < 5:
		selected_cards.append(card)
		card.select()
	
	game.set_hand(CardManager.calculate_hand(selected_cards))
	updateClickUI.emit()

func _on_card_dragged(dragged_card):
	var furthest_card = null
	for card in get_children():
		if (dragged_card.position.x > card.position.x): # card is to the left
			if (furthest_card == null or card.position.x > furthest_card.position.x):
				furthest_card = card
	
	if (furthest_card != null):
		hand.erase(dragged_card)
		
		var index = get_index_from_node(furthest_card)
		hand.insert(index, dragged_card)
		return_hand(false)
	
	# dragged to the leftmost position
	else:
		hand.erase(dragged_card)
		hand.append(dragged_card)
		return_hand(false)		

func get_index_from_node(node: Node2D) -> int:
	for i in range(hand.size()):
		if (hand[i].data.id == node.get_id()):
			return i
	return -1


func create_hand():
	for i in range(hand_size):
		hand.append(null)

func clear_hand():
	for i in range(hand_size):
		hand[i] = null

func delete_hand():
	for card in get_children():
		if card.has_method("get_data"):
			card.queue_free()
	hand.clear()

func shuffle():
	deck.shuffle()

func get_hand_position(card_id):
	for i in range(hand_size):
		if hand[i] == null:
			continue
		if hand[i].data.id == card_id:
			return i
	return -1


func get_checkdeck(is_full_deck: bool) -> Array:
	var checkdeck
	if (is_full_deck):
		checkdeck = fulldeck
	else:
		checkdeck = deck
	return checkdeck

func get_deck_count(key: String, value: int, is_full_deck: bool) -> int:
	var checkdeck = get_checkdeck(is_full_deck)
	
	var count = 0
	for card in checkdeck:
		if card[key] == value:
			count += 1
	return count
func get_numbered_count(is_full_deck) -> int:
	var checkdeck = get_checkdeck(is_full_deck)
	
	var count = 0
	for card in checkdeck:
		if card.rank < 11:
			count += 1
	return count
func get_face_count(is_full_deck) -> int:
	var checkdeck = get_checkdeck(is_full_deck)
	var count = 0
	
	for card in checkdeck:
		if card.rank > 10:
			count += 1
	return count

func sort_hand():
	if is_rank_sort:
		sort_suit()
		sort_rank()
	else:
		sort_rank()
		sort_suit()

func sort_rank():	
	hand.sort_custom(func(a, b):
		if a.data == null and b.data != null:
			return false
		elif b.data == null and a.data != null:
			return true
		elif a.data == null and b.data == null:
			return false
		
		return a.data.rank < b.data.rank
	)
	
	return_hand()

func sort_suit():	
	hand.sort_custom(func(a, b):
		if a.data == null and b.data != null:
			return false
		elif b.data == null and a.data != null:
			return true
		elif a.data == null and b.data == null:
			return false
		
		return a.data.suit > b.data.suit
	)
	return_hand()

# place cards into hand order
func return_hand(reconfig_z = true):
	for card in get_children():
		if card.has_method("get_id"):
			
			for i in range(hand_size):
				if hand[i] == null:
					continue
				if card.get_id() == hand[i].data.id:
					card.position.x = get_card_position(i, count_cards_in_hand())
					
					if card in selected_cards:
						card.position.y = -14
					else:
						card.position.y = 0
					
					if reconfig_z:
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
		if card != null:
			i += 1
	return i

func setup_connection():
	for card in get_children():
		card.connect("card_clicked", Callable(self, "_on_card_clicked"))
		card.connect("dragged", Callable(self, "_on_card_dragged"))


func _on_cash_out_button_pressed() -> void:
	await game.cashout()
	updateButtonsUI.emit()


func _on_next_round_button_pressed() -> void:
	await game.next_round()
	begin_round()

func get_game_state() -> Dictionary:
	return {
		"held_cards": hand,
		"played_cards": selected_cards,
		"deck": deck,
	}
