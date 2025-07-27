extends Sprite2D

@onready var game = $"../.."

var consumables = []
var max_consumables = 2
const BASE_CONSUMABLES = 2


func add(consum):
	consumables.append(consum)
	add_child(consum)
	consum.position = Vector2(-12,-6)
	reorganise_consumables()
	connect_consumables()

func use(consum):
	pass

func _on_clicked(card):
	card.set_consumable()

# 
func use_attempt():
	print("used in consumables")

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
	for card in get_children():
		card.connect("card_clicked", Callable(self, "_on_clicked"))
		card.connect("use_click_forwarded", Callable(self, "_use_attempt"))
		card.connect("sell_click_forwarded", Callable(self, "_on_sell"))
