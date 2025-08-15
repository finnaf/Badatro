extends Sprite2D

@onready var game = $"../.."
@onready var deck = $"../../Deck"

var jok_select = null
var jokers = []
var max_jokers = 5
const BASE_MAX_JOKERS = 5

# score the card for each joker, return values for animating
func score_card(card) -> Array:
	var joker_scores = []
	for joker in jokers:
		var vals = joker.data.get_trigger_val(card.data)
		if (not vals.is_empty()):
			joker_scores.append(vals)
	return joker_scores
		

# score each joker and do animating
func score_jokers(active_cards: Array):
	# get all values needed for joker scoring
	var state = get_joker_score_state()
	state.merge({"active_cards": active_cards})
	
	for joker in jokers:	
		var editionval = joker.data.get_edition_val()
		await game.add_resources(joker, editionval)
		
		var scoreval = joker.data.get_score_val(state, active_cards)
		await game.add_resources(joker, scoreval)
		
		joker.data.update_variable(state, scoreval)

func get_joker_score_state() -> Dictionary:
	var state: Dictionary = game.get_game_state()
	state.merge(deck.get_game_state())
	state.merge({
		"jokers": jokers,
		"max_jokers": get_max_jokers(),
	})
	
	return state



func update_variable_all_jokers():
	var state = get_joker_score_state()
	
	for joker in jokers:
		joker.data.update_variable(state)

func add(joker):
	jokers.append(joker)
	add_child(joker)
	joker.position = Vector2(0,-6)
	joker.card_buttons.z_index += 5
	reorganise_jokers()
	connect_jokers()
	update_variable_all_jokers()

func reorganise_jokers():
	for i in range(jokers.size()):
		jokers[i].position.x = get_joker_position(i)
		jokers[i].position.y = -6

func _on_card_dragged(d_joker):
	jokers.erase(d_joker)

	var insert_index = 0
	for i in range(jokers.size()):
		if d_joker.position.x > jokers[i].position.x:
			insert_index = i + 1
		else:
			break

	jokers.insert(insert_index, d_joker)
	reorganise_jokers()

func _on_clicked(card):
	if (card == jok_select):
		jok_select = null
		card.jok_deselect()
	else:
		if jok_select != null:
			jok_select.consum_deselect()
		jok_select = card
		card.jok_select()


func get_sell_total() -> int:
	var total = 0
	for joker in jokers:
		total += joker.data.get_sell_price()
	return total

func _on_sell(card):
	game.add_money(card.data.get_sell_price())
	_delete_joker(card)
	reorganise_jokers()
	
func _delete_joker(card):
	jokers.erase(card)
	if (jok_select == card):
		jok_select = null
	card.queue_free()

func is_full():
	if (jokers.size() < get_max_jokers()):
		return false
	return true

func get_max_jokers():
	return max_jokers + VoucherCardData.extra_joker_slots

func get_joker_position(i):
	var spacing = round((55)/jokers.size())
	var total_width = (jokers.size() - 1) * spacing
	return ((i * spacing) - (total_width/2)) - 5

func connect_jokers():
	# TODO should i check connection already exists?
	for joker in jokers:
		joker.connect("dragged", Callable(self, "_on_card_dragged"))
		joker.connect("card_clicked", Callable(self, "_on_clicked"))
		joker.connect("button_click_forwarded", Callable(self, "_on_sell"))
		joker.connect("created_desc_box", Callable(self, "_update_variable_in_jok"))
			

func _update_variable_in_jok(card):
	card.data.update_variable(get_joker_score_state())
