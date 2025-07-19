extends Area2D

signal card_clicked(card)
signal buy_click_forwarded(card)

@onready var image: Sprite2D = $Image
@onready var anim: AnimationPlayer = $AnimationPlayer

var is_shop = false
var flipped = true
var tex: Texture2D = null
var cost_label: Sprite2D = null

const SELECT_DIST = 14
const SHOP_SELECT_DIST = 5

var data = {
	"id": null, # unique for each joker / booster / voucher
	"type": CardManager.CardType.none,
	
	# rank & suit & enhancement & seal & raised for card
	# booster_type and booster_size for boosters
	# edition for card & joker
	# consumables TODO
}

func setup(new_data: Dictionary):
	data = new_data
	
	if not new_data.has("type"):
		print("Invalid access to setup method.")
		return
	match data.type:
		CardManager.CardType.card:
			set_card(str(data.rank), data.suit)
		CardManager.CardType.joker:
			set_joker(data.id)
		CardManager.CardType.booster:
			set_booster(data.id, data.booster_size)
		CardManager.CardType.voucher:
			pass
	
func set_card(rank: String, suit: String):
	var path = "res://images/cards/%s/%s%s.png" % [suit, rank, suit]
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex

func set_joker(joker: JokerManager.Jokers):
	if (joker > JokerManager.Jokers.size()):
		return
	
	var joker_data = JokerManager.get_joker(joker)
	var path = ("res://images/cards/jokers/%s/%s.png" % 
				[JokerManager.get_rarity_string(joker_data[1]), joker])
	
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex

func set_booster(booster: CardManager.BoosterType, size: CardManager.BoosterSize):	
	var path = ("res://images/cards/boosters/%s-%s.png" % 
				[str(booster), str(size)])
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
	
func flip():
	if (data.type != CardManager.CardType.card and
		data.type != CardManager.CardType.joker):
		print("cant flip")
		return
	
	if flipped:
		anim.play("flip")
	
	flipped = !flipped

func select():
	if is_shop:
		return

	if (data.type == CardManager.CardType.card and not data.raised):
		position.y -= SELECT_DIST
		data.raised = true

func deselect():
	if is_shop:
		return
	
	if (data.type == CardManager.CardType.card and data.raised):
		position.y += SELECT_DIST
		data.raised = false

func display_cost():
	var cost_val = CardManager.get_card_cost(data)
	
	const COST = preload("res://scenes/card-info-small.tscn")
	cost_label = COST.instantiate()
	add_child(cost_label)
	cost_label.set_value(cost_val, data.type)
	
	cost_label.connect("buy_clicked",
						Callable(self, "_on_buy_clicked_on_label"))

func delete_cost():
	if (cost_label):
		cost_label.queue_free()

func _on_buy_clicked_on_label(card):
	emit_signal("buy_click_forwarded", self)

func shop_select():
	if not is_shop:
		return
		
	position.y -= SHOP_SELECT_DIST
	cost_label.display_button()

func shop_deselect():
	if not is_shop:
		return
	
	cost_label.hide_button()
	position.y += SHOP_SELECT_DIST

func _input_event(viewport, event, shape_idx):
	var pressed = false
	if (event is InputEventMouseButton and event.pressed 
		and event.button_index == MOUSE_BUTTON_LEFT):
		
		if (data.type == CardManager.CardType.card):
			emit_signal("card_clicked", self)
		
		elif (is_shop):
			emit_signal("card_clicked", self)

func set_shop_card():
	is_shop = true
func unset_shop_card():
	is_shop = false
func is_joker():
	if (data.type == CardManager.CardType.joker):
		return true
	return false
func get_data():
	return data
func get_suit():
	return data.suit
func get_rank():
	return data.rank
func get_id():
	return data.id
func is_raised():
	if (data.type == CardManager.CardType.card):
		return data.raised
	print("Card type cannot be raised:", data)
func is_flipped():
	return flipped
