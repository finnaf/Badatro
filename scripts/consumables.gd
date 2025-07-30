extends Sprite2D

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

func use(consum):
	pass

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
	game.add_money(CardManager.get_sell_price(card.data, 1))
	_delete_consumable(card)
# 
func use_attempt(card):
	if (ConsumableManager.can_use([], card)):
		ConsumableManager.use([], card)
		_delete_consumable(card)

func reorganise_consumables():
	for i in range(consumables.size()):
		consumables[i].position.x = get_consumable_position(i)
		consumables[i].position.y = -6

func is_full():
	if (consumables.size() >= max_consumables):
		return true
	return false

func get_consumable_position(i):
	var spacing = round((26)/consumables.size())
	var total_width = (consumables.size() - 1) * spacing
	return ((i * spacing) - (total_width/2)) - 5

func connect_consumables():
	for card in consumables:
		card.connect("card_clicked", Callable(self, "_on_clicked"))
		card.connect("use_click_forwarded", Callable(self, "use_attempt"))
		card.connect("button_click_forwarded", Callable(self, "_on_sell"))
