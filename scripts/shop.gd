extends Node2D

const CARD = preload("res://scenes/card.tscn")

var MAIN_MAX = 2 # dont go above 5
var cards_remaining
var packs_remaining
var vouchers_remaining

var main: Array = []
var boosters: Array = []
var vouchers: Array = []
var booster_cards: Array = []

var main_select = null
var booster_select = null

var in_booster_select = null
var in_booster: bool = false
var in_booster_count: int = 0

const BOOSTER_OFFSET = 27
const VOUCHER_X_OFFSET = -20

@onready var sidebar = $ShopSidebar
@onready var background = $ShopBackground
@onready var skip_button = $SkipButton
@onready var jokers = $"../Mat/Jokers"
@onready var deck_info = $"../Mat/DeckInfo"
@onready var game = $".."


@onready var RerollCostOnes = $ShopBackground/RerollButton/RerollCostOnes
@onready var RerollCostTens = $ShopBackground/RerollButton/RerollCostTens
@onready var RerollCostHundreds = $ShopBackground/RerollButton/RerollCostHundreds

func _ready():
	RerollCostOnes.modulate = Globals.YELLOW
	RerollCostTens.modulate = Globals.YELLOW
	RerollCostHundreds.modulate = Globals.YELLOW

func prep_values():
	cards_remaining = MAIN_MAX
	packs_remaining = 2
	vouchers_remaining = 1
	self.visible = true

func open():
	prep_values()
	sidebar.play()
	update_reroll_display()
	deck_info.enter_shop()

	load_cards()
	setup_connections()

func close():
	for card in main:
		card.queue_free()
	for pack in boosters:
		pack.queue_free()
	self.visible = false
	main.clear()
	boosters.clear()
	deck_info.exit_shop()

func set_pack_background():
	skip_button.visible = in_booster
	background.visible = not in_booster
	deck_info.visible = not in_booster
	
	for card in main:
		card.visible = not in_booster
	for pack in boosters:
		pack.visible = not in_booster
	for voucher in vouchers:
		voucher.visible = not in_booster

func load_cards():
	load_main()
	
	var offsets = get_card_x_offsets(packs_remaining)
	for i in range(packs_remaining):
		get_booster(offsets[1] + (i*offsets[0]))
	
	load_voucher()

# load the main section of the shop
func load_main():
	var offsets = get_card_x_offsets(cards_remaining)
	for i in range(cards_remaining):
		get_main_card(offsets[1] + (i*offsets[0]))

# only one main section or booster card selected at a time
func _on_card_clicked(card):
	if (card.data.type == CardManager.CardType.booster):
		if (card == booster_select):
			booster_select = null
			card.shop_deselect()
		else:
			if booster_select != null:
				booster_select.shop_deselect()
			booster_select = card
			card.shop_select()
	else:
		if (card == main_select):
			main_select = null
			card.shop_deselect()
		else:
			if main_select != null:
				main_select.shop_deselect()
			main_select = card
			card.shop_select()

func get_main_card(xoffset: int):
	var card = CARD.instantiate()
	
	add_child(card)
	card.position.x = xoffset
	card.position.y += 1
	
	# decide if planet, tarot, joker or playing card
	
	var data = JokerManager.generate_joker_data()
	card.setup({
				"id": data.id,
				"rarity": data.rarity,
				"type": CardManager.CardType.joker,
				"edition": data.edition,
			})
	
	card.display_cost()
	card.set_shop_card()
	main.append(card)

func get_booster(xoffset: int):
	var booster = CARD.instantiate()
	
	add_child(booster)
	booster.position.x = xoffset
	booster.position.y = BOOSTER_OFFSET
	booster.setup({
				"id": CardManager.BoosterType.buffoon,
				"type": CardManager.CardType.booster,
				"booster_size": CardManager.BoosterSize.normal,
				"booster_type": CardManager.BoosterType.buffoon
			})
	booster.display_cost()
	booster.set_shop_card()
	boosters.append(booster)

func load_voucher():
	var voucher = CARD.instantiate()
	add_child(voucher)
	voucher.position.x = VOUCHER_X_OFFSET
	voucher.position.y = BOOSTER_OFFSET
	voucher.setup({
				"id": CardManager.VoucherType.voucher,
				"type": CardManager.CardType.voucher,
			})
	voucher.display_cost()
	voucher.hide_cost_only()
	voucher.set_shop_card()
	vouchers.append(voucher)

# returns offset, and starting offset
func get_card_x_offsets(total: int):
	match total:
		1:
			return [0, 12]
		2:
			return [18, 3]
		3:
			return [12, 0]
		4:
			return [8, 0]
		_:
			return 0

# same as the deck.gd logic
func setup_connections():
	update_buy_labels()
	for card in get_children():
		if card.has_method("is_flipped"):
			card.connect("card_clicked", 
						Callable(self, "_on_card_clicked"))
			card.connect("buy_click_forwarded", 
						Callable(self, "_buy_attempt"))

func setup_booster_connections():
	for card in booster_cards:
		card.connect("card_clicked", 
						Callable(self, "_in_booster_card_clicked"))
		card.connect("buy_click_forwarded", 
			Callable(self, "_get_clicked"))

func _buy_attempt(card):
	# TODO also constellation cards
	
	var cost = CardManager.get_card_cost(card.data)
	if (card.data.type == CardManager.CardType.joker):
		if (jokers.is_full()):
			return
		if (game.spend_money(cost)):
			buy_joker(card)
	
	elif (card.data.type == CardManager.CardType.booster):
		if (game.spend_money(cost)):
			open_booster(card)
	
	elif (card.data.type == CardManager.CardType.voucher):
		if (game.spend_money(cost)):
			buy_voucher(card)

# in a booster, the get is clicked
func _get_clicked(card):
	card.delete_cost()
	booster_cards.erase(card)
	in_booster_select = null
	remove_child(card)
	card.disconnect("card_clicked", 
					Callable(self, "_in_booster_card_clicked"))
	in_booster_count -= 1
	jokers.add(card)
	card.unset_shop_card()
	
	if (in_booster_count == 0):
		close_booster()

func _in_booster_card_clicked(card):
	if card == in_booster_select:
		in_booster_select = null
		card.shop_deselect()
	else:
		if in_booster_select != null:
			in_booster_select.shop_deselect()
		in_booster_select = card
		card.shop_select()
		
		if (jokers.is_full()):
			card.cost_label.disable()
		
		
func buy_joker(joker):
	joker.shop_deselect()
	joker.delete_cost()
	joker.unset_shop_card()
	
	remove_child(joker)
	jokers.add(joker)
	main.erase(joker)

func buy_voucher(voucher):
	vouchers.erase(voucher)
	voucher.queue_free()

func open_booster(booster):
	boosters.erase(booster)
	booster.queue_free()
	
	in_booster = true
	set_pack_background()
	
	match booster.data.booster_type:
		CardManager.BoosterType.buffoon:
			open_buffoon(booster.data.booster_size)
	
	
	setup_booster_connections()	

func close_booster():
	if (in_booster):
		in_booster = false
		set_pack_background()
		
		for card in booster_cards:
			card.queue_free()
		booster_cards.clear()

func open_buffoon(size: CardManager.BoosterSize):
	var joker_count = 2
	in_booster_count = 1
	
	if (size == CardManager.BoosterSize.jumbo):
		joker_count = 4
	elif (size == CardManager.BoosterSize.mega):
		joker_count = 6
		in_booster_count = 2
		
	for i in range(joker_count):
		var joker = CARD.instantiate()
		add_child(joker)
		booster_cards.append(joker)
		
		# create a card info, hide top cost
		joker.display_cost()
		joker.set_shop_card()
		joker.cost_label.switch_label(true)
		joker.cost_label.hide_button()
		
		joker.position = Vector2((i*13), 5)
		
		var data = JokerManager.generate_joker_data()
		joker.setup(data)

func update_reroll_display():
	var digits = Globals.convert_to_digits(
					game.get_reroll_cost(), 3, 999)
	
	RerollCostOnes.frame = digits[0]
	RerollCostTens.frame = digits[1]
	RerollCostOnes.frame = digits[2]

func update_buy_labels():
	for card in main:
		if (card.cost_label):
			if (card.cost_label.card_cost > game.money or 
				(card.data.type == CardManager.CardType.joker and 
				jokers.is_full())):
				card.cost_label.disable()
			else:
				card.cost_label.enable()
	
	for card in boosters:
		if (card.cost_label):
			if (card.cost_label.card_cost > game.money):
				card.cost_label.disable()
			else:
				card.cost_label.enable()
	
	for card in vouchers:
		if (card.cost_label):
			if (card.cost_label.card_cost > game.money):
				card.cost_label.disable()
			else:
				card.cost_label.enable()
				
func _on_reroll_button_pressed() -> void:
	var cost = game.get_reroll_cost()
	
	# failed to buy
	if (not game.spend_money(cost)):
		return
	
	for card in main:
		card.queue_free()
	main.clear()
	
	load_main()
	game.process_reroll()
	update_reroll_display()
	setup_connections()

func _on_skip_button_pressed() -> void:
	if (in_booster):
		close_booster()
