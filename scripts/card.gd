extends Area2D

signal card_clicked(card)
signal button_click_forwarded(card)
signal use_click_forwarded(card)
signal dragged(card)

@export var symbols: SpriteFrames

@onready var image: Sprite2D = $Image
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var box: Script = preload("res://scripts/joker-descriptor.gd")

var is_focused: bool = false
var is_shop: bool = false
var flipped: bool = true

var tex: Texture2D = null
var card_buttons: Sprite2D = null
var desc_box: Node2D = null

const FOCUS_SIZE = Vector2(1.0909090909, 1.07692307692)

const SHIFT_DIST = Vector2(0.5, 0.5)
const SELECT_DIST = 14
const SHOP_SELECT_DIST = 5

var data = {
	"id": null, # unique for each joker / booster / voucher
	"type": CardManager.CardType.none,
	
	# rank & suit & enhancement & seal & raised for card
	# booster_type and booster_size for boosters
	# edition for card & joker
	# rarity, scale_value for joker
	# consumable_type for consumables
}

func _ready():
	connect("mouse_entered", Callable(self, "on_mouse_entered"))
	connect("mouse_exited", Callable(self, "on_mouse_exited"))

func setup(new_data: Dictionary):
	data = new_data
	
	if not data.has("type"):
		print("Invalid access to setup method.")
		return
	match data.type:
		CardManager.CardType.card:
			set_card_tex(data.rank, data.suit)
		CardManager.CardType.joker:
			set_joker_tex(data.id, data.rarity)
		CardManager.CardType.booster:
			set_booster_tex(data.id, data.booster_size)
		CardManager.CardType.voucher:
			set_voucher_tex(data.id)
		CardManager.CardType.consumable:
			set_consumable_tex(data.consumable_type, data.id)
	if data.has("edition"):
		draw_edition(data.edition)
	
func set_card_tex(rank: int, suit: int):
	var suit_str = CardManager.get_suit_name(suit)
	var path = "res://images/cards/%s/%s%s.png" % [suit_str, str(rank), suit_str]
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
func set_joker_tex(joker_id, rarity):	
	var joker_data = JokerManager.get_joker(joker_id, rarity)
	var path = ("res://images/cards/jokers/%s/%s.png" % 
				[JokerManager.get_rarity_string(rarity), 
				JokerManager.get_joker_shortname(joker_id, rarity)])
	
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
func set_booster_tex(booster: CardManager.BoosterType, size: CardManager.BoosterSize):	
	var path = ("res://images/cards/boosters/%s-%s.png" % 
				[str(booster), str(size)])
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
func set_voucher_tex(voucher: CardManager.VoucherType):
	var path = ("res://images/cards/vouchers/voucher.png")
	tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
func set_consumable_tex(consumable: CardManager.ConsumableType, id):
	match consumable:
		CardManager.ConsumableType.planet:
			var path = ("res://images/cards/planets/planet_bg.png")
			tex = CardManager.get_card_texture(path)
			if tex:
				image.texture = tex
			
			add_child(Globals.create_symbol_sprite(id, "planets", Vector2(5.5, 8.5)))

func draw_edition(edition: CardManager.Edition): # TODO
	var animation

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

func delete_card_buttons():
	if (card_buttons):
		card_buttons.queue_free()

func _on_button_clicked_on_label(card):
	emit_signal("button_click_forwarded", self)
func _on_use_clicked_on_label(card):
	emit_signal("use_click_forwarded", self)

func shop_select():
	if card_buttons == null:
		return
		
	position.y -= SHOP_SELECT_DIST
	card_buttons.display_button()
	
	if (is_consumable()):
		card_buttons.display_use()

func shop_deselect():
	if card_buttons == null:
		return
	
	card_buttons.hide_button()
	if (is_consumable()):
		card_buttons.hide_use()
	position.y += SHOP_SELECT_DIST

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			MouseManager.start_drag(self, event.position)

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
	if (MouseManager.is_dragging or MouseManager.card_disabled(self)):
		return
	
	if is_shop_card():
		Globals.do_shake(self, 1.01)
		if not is_joker():
			return
	else:
		if is_joker():
			pass # removing joker focusing
		else:
			self.position -= SHIFT_DIST
			self.scale = FOCUS_SIZE
		
		is_focused = true
		self.z_index += 5
	
	if is_joker():
		self.z_index += 1 # for descriptor to be able to fit between bg and card
		var desc_data = JokerManager.get_joker(get_id(), get_rarity())
		desc_box = box.new(desc_data)
		add_child(desc_box)

func on_mouse_exited():
	if (MouseManager.is_dragging or MouseManager.card_disabled(self)):
		return
	
	reset_focus()

func reset_focus():
	if is_focused:
		if is_shop_card():
			pass
		elif is_joker():
			pass
		else:
			position += SHIFT_DIST
		
		scale = Vector2.ONE
		z_index -= 5
		is_focused = false
	
	if desc_box:
		z_index -= 1
		desc_box.queue_free()
		desc_box = null

			
func set_shop_card():
	is_shop = true
func unset_shop_card():
	is_shop = false
func is_shop_card():
	return is_shop

func display_cost():
	var cost_val = CardManager.get_card_cost(data, 1)
	card_buttons = preload("res://scenes/card-info-small.tscn").instantiate()
	add_child(card_buttons)
	card_buttons.set_value(cost_val, data.type)
	
	card_buttons.connect("button_clicked", Callable(self, "_on_button_clicked_on_label"))
	card_buttons.connect("use_clicked", Callable(self, "_on_use_clicked_on_label"))

func setup_sell_price():
	if (card_buttons):
		var sell_val = CardManager.get_sell_price(data, 1)
		card_buttons.set_value(sell_val, data.type)
		card_buttons.switch_label(2)


func setup_consumable():
	card_buttons.z_index += 5
	setup_sell_price()
	card_buttons.switch_use_side()
	
	consum_deselect()
	

func consum_select():
	setup_sell_price()
	card_buttons.show()
	card_buttons.display_use()
	card_buttons.display_button()

func consum_deselect():
	card_buttons.hide_use()
	card_buttons.hide_button()
	card_buttons.clear_score()

func display_use():
	if (card_buttons):
		card_buttons.show()
		card_buttons.display_use()

func hide_cost_only():
	if (card_buttons):
		card_buttons.hide_cost()
func hide_button_only():
	if (card_buttons):
		card_buttons.hide_button()
func hide_use_only():
	if (card_buttons):
		card_buttons.hide_use()
func hide_buttons():
	card_buttons.hide()

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
func is_planet():
	if (is_consumable() and 
		data.consumable_type == CardManager.ConsumableType.planet):
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
