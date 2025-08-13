extends Sprite2D

# TODO fix DRAG END!

@onready var game = $"../.."

var consum_select = null

var consumables = []
var max_consumables = 2
const BASE_CONSUMABLES = 2

func add(consum):
	consumables.append(consum)
	add_child(consum)
	consum.setup_consumable()
	consum.position = Vector2(-12,-6)
	reorganise_consumables()
	connect_consumables()

func use(selected_cards: Array, consumable: Node2D):
	if (consumable.data.is_planet()):
		var hand = ConsumableCardData.get_planet_name(consumable.data.id)
		await game.upgrade_hand(hand)
		
		# update current hand if is playing it
		if (game.state == game.states.PLAYING and
			game.hand == hand):
			game.set_hand(hand)
	
	elif (consumable.data.is_tarot()):
		print("use tarot")
		

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
	if (ConsumableCardData.can_use([], card)):
		use([], card)
		_delete_consumable(card)

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
