extends Sprite2D

const CARD = preload("res://scenes/card.tscn")

@onready var game = $"../.."
@onready var shop = $"../../Shop" # use in boosters TODO
@onready var deck = $"../../Deck" # use in game
@onready var jokers = $"../Jokers" # use in game

var consum_select = null

var consumables = []
var max_consumables = 2
const BASE_CONSUMABLES = 2

var last_used: Node2D = null

func add(consum: Node2D):
	consumables.append(consum)
	add_child(consum)
	consum.setup_consumable()
	consum.position = Vector2(-12,-6)
	reorganise_consumables()
	connect_consumables()

# dont delete, just use
func use(selected_cards: Array, consumable: Node2D):
	if (consumable.data.is_planet()):
		var hand = ConsumableCardData.get_planet_name(consumable.data.id)
		await game.upgrade_hand(hand)
		
		# update current hand if is playing it
		if (game.state == game.states.PLAYING and
			game.hand == hand):
			game.set_hand(hand)
	
	elif (consumable.data.is_tarot()):
		_use_tarot(selected_cards, consumable)

func _use_tarot(selected_cards: Array, tarot: Node2D):
	match tarot.get_id():
		ConsumableCardData.Tarot.Fool:
			if (last_used == null or last_used.data.is_fool()):
				return -1
			
			consumables.add(last_used)
		
		ConsumableCardData.Tarot.Magician:
			if (tarot.data.has_one_or_two(selected_cards)):
					return -1
			
			for card in selected_cards:
				card.data.enhancement = CardManager.Enhancement.lucky
				card.setup(card.data)
			
		ConsumableCardData.Tarot.HighPriestess:
			if consumables.size() >= get_consumable_count():
				return -1
			
			_add_up_to_two(ConsumableCardData.ConsumableType.planet)
		
		ConsumableCardData.Tarot.Empress:
			if not tarot.data.has_one_or_two(selected_cards):
				return -1
			
			for card in selected_cards:
				card.data.enhancement = CardManager.Enhancement.mult
				card.setup(card.data)
		
		ConsumableCardData.Tarot.Emperor:
			if consumables.size() >= get_consumable_count():
				return -1
			_add_up_to_two(ConsumableCardData.ConsumableType.tarot)
		
		ConsumableCardData.Tarot.Hierophant:
			if (selected_cards.size() > 3 or
				selected_cards.is_empty()):
					return -1
			
			for card in selected_cards:
				card.data.enhancement = CardManager.Enhancement.bonus
				card.setup(card.data)
		
		ConsumableCardData.Tarot.Lovers:
			if (selected_cards.size() != 1):
					return -1
			
			selected_cards[0].data.enhancement = CardManager.Enhancement.wild
			selected_cards[0].setup(selected_cards[0].data)
		
		ConsumableCardData.Tarot.Chariot:
			if (selected_cards.size() != 1):
					return -1
			
			selected_cards[0].data.enhancement = CardManager.Enhancement.steel
			selected_cards[0].setup(selected_cards[0].data)
		
		ConsumableCardData.Tarot.Justice:
			if (selected_cards.size() != 1):
					return -1
			
			selected_cards[0].data.enhancement = CardManager.Enhancement.glass
			selected_cards[0].setup(selected_cards[0].data)
		
		ConsumableCardData.Tarot.Hermit:
			# TODO no animation as have to delete card earlier
			game.add_money(min(20, game.money*2))
		
		ConsumableCardData.Tarot.WheelOfFortune:
			pass # TODO
		ConsumableCardData.Tarot.Strength:
			if not tarot.data.has_one_or_two(selected_cards):
				return -1
			
			for card in selected_cards:
				card.data.rank += 1
				
				if (card.data.rank >= 15):
					card.data.rank = 2
				
				card.setup(card.data)
		
		ConsumableCardData.Tarot.HangedMan:
			if not tarot.data.has_one_or_two(selected_cards):
				return -1
			
			for card in selected_cards:
				deck.remove_card(card.data)
				card.queue_free()
			deck.selected_cards.clear()
		
		ConsumableCardData.Tarot.Death: # right convert to left
			if (selected_cards.size() != 2):
				return -1
			
			selected_cards[1].setup(selected_cards[0].data)
			# TODO BUG, changed card not played until double clicked
	
		ConsumableCardData.Tarot.Temperance:
			game.add_money(min(50, jokers.get_sell_total()))
		
		ConsumableCardData.Tarot.Devil:
			if (selected_cards.size() != 1):
					return -1
			
			selected_cards[0].data.enhancement = CardManager.Enhancement.gold
			selected_cards[0].setup(selected_cards[0].data)
		
		ConsumableCardData.Tarot.Tower:
			if (selected_cards.size() != 1):
				return -1
			
			selected_cards[0].data.enhancement = CardManager.Enhancement.stone
			selected_cards[0].setup(selected_cards[0].data)
		
		ConsumableCardData.Tarot.Star:
			if (selected_cards.size() > 3 or
				selected_cards.is_empty()):
					return -1
					
			_change_cards_suit(selected_cards, CardManager.Suit.diamonds)

		ConsumableCardData.Tarot.Moon:
			if (selected_cards.size() > 3 or
				selected_cards.is_empty()):
					return -1
					
			_change_cards_suit(selected_cards, CardManager.Suit.clubs)
		
		ConsumableCardData.Tarot.Sun:
			if (selected_cards.size() > 3 or
				selected_cards.is_empty()):
					return -1
			_change_cards_suit(selected_cards, CardManager.Suit.hearts)
		
		ConsumableCardData.Tarot.World:
			if (selected_cards.size() > 3 or
				selected_cards.is_empty()):
					return -1
			_change_cards_suit(selected_cards, CardManager.Suit.spades)
		
		ConsumableCardData.Tarot.Judgement:
			var jok = CARD.instantiate()
			add_child(jok)
			jok.setup(JokerCardData.new())
			jok.display_cost()
			jok.hide_cost_only()
			remove_child(jok)
			jokers.add(jok)
	last_used = tarot

func _add_up_to_two(type: ConsumableCardData.ConsumableType):
	var card1 = CARD.instantiate()
	add_child(card1)
	card1.setup(ConsumableCardData.new(type))
	card1.display_cost()
	add(card1)
			
	if (consumables.size() < get_consumable_count()):
		var card2 = CARD.instantiate()
		add_child(card2)
		card2.setup(ConsumableCardData.new(type))
		card2.display_cost()
		add(card2)

func _change_cards_suit(cards: Array, suit: CardManager.Suit):
	for card in cards:
		card.data.suit = suit
		card.setup(card.data)

func _on_clicked(card):
	if (card == consum_select):
		consum_select = null
		card.consum_deselect()
	else:
		if consum_select != null:
			consum_select.consum_deselect()
		consum_select = card
		card.consum_select()

func _delete_consumable(card):
	consumables.erase(card)
	if (consum_select == card):
		consum_select = null
	card.queue_free()

func _on_sell(card):
	var cost = card.data.get_cost()
	game.add_money(cost)
	_delete_consumable(card)
# 
func use_attempt(card):	
	if (game.state == game.states.PLAYING):
		print("playing")
		print(deck.selected_cards)
		if (card.data.can_use(deck.selected_cards)):
			_delete_consumable(card)
			use(deck.selected_cards, card)
	
	# TODO in booster card state
	elif (game.state == game.states.SHOPPING):
		if (card.data.can_use([])):
			_delete_consumable(card)
			use([], card)

func reorganise_consumables():
	for i in range(consumables.size()):
		consumables[i].position.x = get_consumable_position(i)
		consumables[i].position.y = -6

func get_consumable_count():
	return max_consumables + VoucherCardData.extra_consumable

func is_full():
	if (consumables.size() >= get_consumable_count()):
		return true
	return false

func get_consumable_position(i):
	var spacing = round((26)/consumables.size())
	var total_width = (consumables.size() - 1) * spacing
	return ((i * spacing) - (total_width/2)) - 6

func _on_card_dragged(card):
	consumables.erase(card)

	var insert_index = 0
	for i in range(consumables.size()):
		if card.position.x > consumables[i].position.x:
			insert_index = i + 1
		else:
			break

	consumables.insert(insert_index, card)
	reorganise_consumables()

func connect_consumables():
	for card in consumables:
		card.connect("card_clicked", Callable(self, "_on_clicked"))
		card.connect("dragged", Callable(self, "_on_card_dragged"))
		card.connect("use_click_forwarded", Callable(self, "use_attempt"))
		card.connect("button_click_forwarded", Callable(self, "_on_sell"))
