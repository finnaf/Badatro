extends Area2D

signal card_clicked(card)
signal buy_click_forwarded(card)
signal dragged(card)

@onready var image: Sprite2D = $Image
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var box: Script = preload("res://scripts/joker-descriptor.gd")

var is_shop: bool = false
var flipped: bool = true
var tex: Texture2D = null
var cost_label: Sprite2D = null
var desc_box: Node2D = null

const SELECT_DIST = 14
const SHOP_SELECT_DIST = 5

var data = {
	"id": null, # unique for each joker / booster / voucher
	"type": CardManager.CardType.none,
	
	# rank & suit & enhancement & seal & raised for card
	# booster_type and booster_size for boosters
	# edition for card & joker
	# rarity, scale_value for joker
	# consumables TODO
}

func _ready():
	connect("mouse_entered", Callable(self, "on_mouse_entered"))
	connect("mouse_exited", Callable(self, "on_mouse_exited"))

func setup(new_data: Dictionary):
	data = new_data
	
	if not new_data.has("type"):
		print("Invalid access to setup method.")
		return
	match data.type:
		CardManager.CardType.card:
			set_card(data.rank, data.suit)
		CardManager.CardType.joker:
			set_joker(data.id, data.rarity)
		CardManager.CardType.booster:
			set_booster(data.id, data.booster_size)
		CardManager.CardType.voucher:
			pass
	
func set_card(rank: int, suit: int):
	var suit_str = CardManager.get_suit_name(suit)
	var path = "res://images/cards/%s/%s%s.png" % [suit_str, str(rank), suit_str]
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex

func set_joker(joker_id, rarity):	
	var joker_data = JokerManager.get_joker(joker_id, rarity)
	data.rarity = joker_data.rarity # edge case where cant pick from given rarity
	var path = ("res://images/cards/jokers/%s/%s.png" % 
				[JokerManager.get_rarity_string(rarity), 
				JokerManager.get_joker_shortname(joker_id, rarity)])
	
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
	if cost_label == null:
		return
		
	position.y -= SHOP_SELECT_DIST
	cost_label.display_button()

func shop_deselect():
	if cost_label == null:
		return
	
	cost_label.hide_button()
	position.y += SHOP_SELECT_DIST

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			DragManager.start_drag(self, event.position)

func _on_drag_start():
	pass
func _on_drag_motion(event):
	position += event.relative
func _on_drag_end():
	dragged.emit(self)


func on_clicked():
	if (data.type == CardManager.CardType.joker):
		var jok_data = JokerManager.get_joker(get_id(), get_rarity())
		print(
			JokerManager.get_rarity_string(jok_data.rarity),
			" ", 
			jok_data.name,
			" - ",
			jok_data.description
		)
			
	emit_signal("card_clicked", self)

func on_mouse_entered():
	if not is_joker():
		return
	
	var desc_data = JokerManager.get_joker(get_id(), get_rarity())
	desc_box = box.new(desc_data)
	add_child(desc_box)
	self.z_index = 2

func on_mouse_exited():
	if not is_joker():
		return
	self.z_index = 0
	desc_box.queue_free()

func set_shop_card():
	is_shop = true
func unset_shop_card():
	is_shop = false
func is_shop_card():
	return is_shop
func is_joker():
	if (data.type == CardManager.CardType.joker):
		return true
	return false
func is_card():
	if (data.type == CardManager.CardType.card):
		return true
	return false
func is_consumable():
	if (data.type == CardManager.CardType.consumable):
		return true
func get_data():
	return data
func get_suit():
	return data.suit
func get_rank():
	return data.rank
func get_id():
	return data.id
func get_rarity():
	if (data.type == CardManager.CardType.joker):
		return data.rarity
	return null
func is_raised():
	if (data.type == CardManager.CardType.card):
		return data.raised
	print("Card type cannot be raised:", data)
func is_flipped():
	return flipped
