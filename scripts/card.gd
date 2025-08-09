extends Area2D

signal card_clicked(card)
signal button_click_forwarded(card)
signal use_click_forwarded(card)
signal dragged(card)


const card_atlas = preload("res://images/cards/cards/cards.png")
const enhance_atlas = preload("res://images/cards/enhancements/enhancements.png")
@export var symbols: SpriteFrames

@onready var image: Sprite2D = $Image
@onready var enhancement: Sprite2D = $Background
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var box: Script = preload("res://scripts/joker-descriptor.gd")

var is_focused: bool = false

var card_buttons: Sprite2D = null
var desc_box: Node2D = null

const FOCUS_SIZE = Vector2(1.0909090909, 1.07692307692)

const SHIFT_DIST = Vector2(0.5, 0.5)
const SELECT_DIST = 14
const SHOP_SELECT_DIST = 5

var data: CardData

func _ready():
	connect("mouse_entered", Callable(self, "on_mouse_entered"))
	connect("mouse_exited", Callable(self, "on_mouse_exited"))
	
func setup(new_data: CardData):
	data = new_data
	
	if (data.is_card()):
		var d := data as PlayingCardData
		set_card_tex(d.rank, d.suit)
		set_enhance_tex(d.enhancement)
	elif (data.is_joker()):
		var d := data as JokerCardData
		set_joker_tex(d.id, d.rarity)
	elif (data.is_booster()):
		var d := data as BoosterCardData
		set_booster_tex(d.booster_type, d.booster_size)
	elif (data.is_voucher()):
		var d := data as VoucherCardData
		set_voucher_tex(data.id)
	elif (data.is_consumable()):
		var d := data as ConsumableCardData
		set_consumable_tex(d.consumable_type, d.id)
	
func set_card_tex(rank: int, suit: int):	
	const SIZE = Vector2(11, 13)
	var tex := AtlasTexture.new()
	tex.atlas = card_atlas
	tex.region = Rect2(
		Vector2((rank-2) * SIZE.x, suit * SIZE.y),
		SIZE
	)
	image.texture = tex
	image.show()

func set_enhance_tex(enhance: CardManager.Enhancement):	
	const SIZE = Vector2(11, 13)
	var tex := AtlasTexture.new()
	tex.atlas = enhance_atlas
	tex.region = Rect2(
		Vector2(((enhance) * SIZE.x) + enhance, 0),
		SIZE
	)
	enhancement.texture = tex
	
	# stone cards dont have a visible rank/suit
	if (enhance == CardManager.Enhancement.stone):
		image.hide()

func set_joker_tex(joker_id, rarity):	
	var path = ("res://images/cards/jokers/%s/%s.png" % 
				[JokerManager.get_rarity_string(rarity), 
				JokerManager.get_joker_shortname(joker_id, rarity)])
	
	var tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
func set_booster_tex(booster: CardManager.BoosterType, size: CardManager.BoosterSize):	
	var path = ("res://images/cards/boosters/%s-%s.png" % 
				[str(booster), str(size)])
	var tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
func set_voucher_tex(voucher: VoucherManager.Voucher):
	var path = ("res://images/cards/vouchers/%s.png" % 
				[VoucherManager.get_voucher_name(voucher)])
	var tex = CardManager.get_card_texture(path)
	if tex:
		image.texture = tex
func set_consumable_tex(consumable: ConsumableManager.ConsumableType, id):
	match consumable:
		ConsumableManager.ConsumableType.planet:
			print("PLANET")
			var path = ("res://images/cards/planets/planet_bg.png")
			var tex = CardManager.get_card_texture(path)
			if tex:
				image.texture = tex
			
			add_child(Globals.create_symbol_sprite(id, "planets", Vector2(5.5, 8.5)))
		ConsumableManager.ConsumableType.tarot:
			print("TAROT")
			var path = ("res://images/cards/planets/planet_bg.png")
			var tex = CardManager.get_card_texture(path)
			if tex:
				image.texture = tex
		ConsumableManager.ConsumableType.spectral:
			print("SPECTRAL")
			var path = ("res://images/cards/planets/planet_bg.png")
			var tex = CardManager.get_card_texture(path)
			if tex:
				image.texture = tex

func draw_edition(edition: CardManager.Edition): # TODO
	var animation

func flip():
	if not (data.is_card() or data.is_joker()):
		print("cant flip")
		return
	
	if data.is_flipped:
		anim.play("flip")
	
	data.is_flipped = not data.is_flipped

func select():
	if data.is_shop:
		return

	if (data.is_card() and not data.is_raised):
		position.y -= SELECT_DIST
		data.is_raised = true

func deselect():
	if data.is_shop:
		return
	
	if (data.is_card() and data.is_raised):
		position.y += SELECT_DIST
		data.is_raised = false

func delete_card_buttons():
	if (card_buttons):
		card_buttons.queue_free()

func _on_button_clicked_on_label(card):
	emit_signal("button_click_forwarded", self)
func _on_use_clicked_on_label(card):
	emit_signal("use_click_forwarded", self)
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
	if (data.is_joker()):
		var jok_data = JokerManager.joker_info[get_id()]
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
		if not data.is_joker():
			return
	else:
		if data.is_joker():
			pass # removing joker focusing
		else:
			self.position -= SHIFT_DIST
			self.scale = FOCUS_SIZE
		
		is_focused = true
		self.z_index += 5
	
	if data.is_joker():
		self.z_index += 1 # for descriptor to be able to fit between bg and card
		var desc_data = JokerManager.joker_info[get_id()]
		desc_box = box.new(desc_data, data)
		add_child(desc_box)

func on_mouse_exited():
	if (MouseManager.is_dragging or MouseManager.card_disabled(self)):
		return
	
	reset_focus()

func reset_focus():
	if is_focused:
		if is_shop_card():
			pass
		elif data.is_joker():
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

func display_cost():
	var cost_val = data.get_cost(1)
	card_buttons = preload("res://scenes/card-info-small.tscn").instantiate()
	add_child(card_buttons)
	card_buttons.set_value(cost_val, data)
	
	card_buttons.connect("button_clicked", Callable(self, "_on_button_clicked_on_label"))
	card_buttons.connect("use_clicked", Callable(self, "_on_use_clicked_on_label"))

func setup_sell_price():
	if (card_buttons):
		var sell_val = data.get_sell_price(1)
		card_buttons.set_value(sell_val, data)
		card_buttons.switch_label(2)


func setup_consumable():
	card_buttons.z_index += 5
	setup_sell_price()
	card_buttons.switch_use_side()
	
	consum_deselect()
	
func shop_select():
	if card_buttons == null:
		return
		
	position.y -= SHOP_SELECT_DIST
	card_buttons.display_button()
	
	if (data.is_consumable()):
		card_buttons.display_use()
func shop_deselect():
	if card_buttons == null:
		return
	
	card_buttons.hide_button()
	if (data.is_consumable()):
		card_buttons.hide_use()
	position.y += SHOP_SELECT_DIST

func jok_select():
	setup_sell_price()
	card_buttons.show()
	card_buttons.display_button()
func jok_deselect():
	card_buttons.hide_button()
	card_buttons.clear_score()

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


func get_data():
	return data
func get_suit():
	var d := data as PlayingCardData
	return d.suit
func get_rank():
	var d := data as PlayingCardData
	return d.rank
func get_id():
	return data.id
func get_rarity():
	var d := data as JokerCardData
	return d.rarity
func get_variable_val():
	var d := data as JokerCardData
	return d.variable
func is_raised():
	var d := data as PlayingCardData
	return d.is_raised
func is_flipped():
	var d := data as PlayingCardData
	return d.is_flipped

func is_shop_card():
	return data.is_shop
func is_card():
	return data.is_card()
func is_joker():
	return data.is_joker()
func is_consumable():
	return data.is_consumable()
