extends Node2D

const CARD = preload("res://scenes/card.tscn")

const MAIN_STANDARD_SIZE = 2
var main_size
var cards_remaining
var packs_remaining
var vouchers_remaining

var rng = RandomNumberGenerator.new()

var main: Array = []
var boosters: Array = []
var vouchers: Array = []
var booster_cards: Array = []

var main_select = null
var booster_select = null
var voucher_select = null

var in_booster_select = null
var in_booster: bool = false
var in_booster_count: int = 0

const BOOSTER_OFFSET = 27
const VOUCHER_X_OFFSET = -20

@onready var sidebar = $ShopSidebar
@onready var background = $ShopBackground
@onready var skip_button = $SkipButton
@onready var jokers = $"../Mat/Jokers"
@onready var consumables = $"../Mat/Consumables"
@onready var deck_info = $"../Mat/DeckInfo"
@onready var deck = $"../Deck"
@onready var game = $".."

@onready var RerollCostOnes = $ShopBackground/RerollButton/RerollCostOnes
@onready var RerollCostTens = $ShopBackground/RerollButton/RerollCostTens
@onready var RerollCostHundreds = $ShopBackground/RerollButton/RerollCostHundreds

func _ready():
	RerollCostOnes.modulate = Globals.YELLOW
	RerollCostTens.modulate = Globals.YELLOW
	RerollCostHundreds.modulate = Globals.YELLOW

func set_seed(s: int):
	rng.seed = s

func prep_values():
	main_size = MAIN_STANDARD_SIZE + VoucherCardData.extra_shop_slots
	cards_remaining = main_size
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
	for voucher in vouchers: # only delete at the start of next ante
		if (voucher == voucher_select):
			voucher_select = null
			voucher.shop_deselect()
		voucher.hide()
	
	self.visible = false
	main.clear()
	boosters.clear()
	deck_info.exit_shop()

func load_cards():
	load_main()
	
	var offsets = get_card_x_offsets(packs_remaining)
	for i in range(packs_remaining):
		get_booster(offsets[1] + (i*offsets[0]))
	
	if game.is_voucher():
		load_voucher()

# load the main section of the shop
func load_main():
	var offsets = get_card_x_offsets(cards_remaining)
	for i in range(cards_remaining):
		get_main_card(offsets[1] + (i*offsets[0]))

func get_main_card(xoffset: int):
	var card = CARD.instantiate()
	var data: CardData
	
	add_child(card)
	card.position.x = xoffset
	card.position.y += 1
	
	# decide if planet, tarot, joker or playing card
	const W_JOK = 20
	const W_TAR = 4
	const W_PLA = 4
	
	# 20 -4 -4
	var type_thresh = rng.randi_range(0, W_JOK + W_TAR + W_TAR)
	
	if type_thresh < W_JOK: # jok
		
		data = JokerCardData.new()
		data.update_variable(jokers.get_joker_score_state())
		
	elif type_thresh < W_JOK + W_TAR:
		data = ConsumableCardData.new(ConsumableCardData.ConsumableType.tarot)
	else: # planet
		data = ConsumableCardData.new(ConsumableCardData.ConsumableType.planet)
	
	data.set_shop_card()
	card.setup(data)
	card.display_cost()
	main.append(card)

func get_booster(xoffset: int):
	var booster = await CARD.instantiate()
	add_child(booster)
	booster.setup(BoosterCardData.new(rng, game.round))
	booster.position.x = xoffset
	booster.position.y = BOOSTER_OFFSET
	booster.display_cost()
	boosters.append(booster)

func load_voucher():
	# TODO logic only handles one voucher rn
	if (not vouchers.is_empty()):
		if game.has_shop_ante_reset():
			for voucher in vouchers:
				voucher.queue_free()
			vouchers.clear()
		else:
			for voucher in vouchers:
				voucher.show()
			return
	
	
	var voucher = CARD.instantiate()
	add_child(voucher)
	
	# pass in rng (voucher affects shop pool)
	voucher.setup(VoucherCardData.new(rng))
	voucher.position.x = VOUCHER_X_OFFSET
	voucher.position.y = BOOSTER_OFFSET + 1
	voucher.display_cost()
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
		if card.has_method("setup"): # is a card
			card.connect("card_clicked", Callable(self, "_on_card_clicked"))
			card.connect("button_click_forwarded", Callable(self, "_buy_attempt"))
			card.connect("use_click_forwarded", Callable(self, "_use_attempt"))

func setup_booster_connections():
	for card in booster_cards:
		card.connect("card_clicked", Callable(self, "_in_booster_card_clicked"))
		card.connect("button_click_forwarded", Callable(self, "_get_clicked"))

# only one main section or booster card selected at a time
func _on_card_clicked(card):
	if (card.data.is_booster()):
		if (card == booster_select):
			booster_select = null
			card.shop_deselect()
		else:
			if booster_select != null:
				booster_select.shop_deselect()
			booster_select = card
			card.shop_select()
	elif (card.data.is_voucher()):
		if (card == voucher_select):
			voucher_select = null
			card.shop_deselect()
		else:
			if voucher_select != null:
				voucher_select.shop_deselect()
			voucher_select = card
			card.shop_select()
	else: # must be a main section card
		if (card == main_select):
			main_select = null
			card.shop_deselect()
		else:
			if main_select != null:
				main_select.shop_deselect()
			main_select = card
			card.shop_select()

func _buy_attempt(card):
	if MouseManager.is_disabled:
		return
		
	var cost = card.data.get_cost()
	if (card.data.is_joker()):
		if (jokers.is_full() or not game.spend_money(cost)):
			return
		buy_joker(card)
		main.erase(card)
		main_select = null
	
	elif (card.data.is_consumable()):
		if (consumables.is_full() or not game.spend_money(cost)):
			return
		buy_consumable(card)
		main.erase(card)
		main_select = null
	
	elif (card.data.is_booster()):
		if (not game.spend_money(cost)):
			return
		open_booster(card)
		
	
	elif (card.data.is_voucher()):
		if (game.spend_money(cost)):
			buy_voucher(card)
			game.voucher_count -= 1
		return
	
	# disconnect from all card signals if it is successfully bought
	card.disconnect("use_click_forwarded", Callable(self, "_use_attempt"))
	card.disconnect("button_click_forwarded", Callable(self, "_buy_attempt"))
	card.disconnect("card_clicked", Callable(self, "_on_card_clicked"))

func _use_attempt(consumable):
	var cost = consumable.data.get_cost()
	var can_use = ConsumableCardData.can_use([], consumable)
	if (can_use and game.spend_money(cost)):
		consumables.use([], consumable)
	
	consumable.queue_free()
	main.erase(consumable)

# in a booster, the get is clicked
func _get_clicked(card):
	if MouseManager.is_disabled:
		return
	

	booster_cards.erase(card)
	in_booster_select = null
	in_booster_count -= 1
	
	if (card.data.is_joker()):
		buy_joker(card)
	elif (card.data.is_consumable()):
		buy_consumable(card)
	elif (card.data.is_playing_card()):
		buy_playing_card(card)
	else:
		print("invalid type got")
	
	card.disconnect("card_clicked", Callable(self, "_in_booster_card_clicked"))
	card.disconnect("button_click_forwarded", Callable(self, "_get_clicked"))
	
	if (in_booster_count == 0):
		close_booster()

# in booster, card is clicked
func _in_booster_card_clicked(card):
	if card == in_booster_select:
		in_booster_select = null
		card.shop_deselect()
	else:
		if in_booster_select != null:
			in_booster_select.shop_deselect()
		in_booster_select = card
		card.shop_select()
		
		if (card.is_joker() and jokers.is_full()):
			card.cost_label.disable()

func sever_shop_connections(card):
	card.shop_deselect()
	card.hide_buttons()
	card.data.unset_shop_card()
	remove_child(card)
		
func buy_joker(joker):
	sever_shop_connections(joker)
	jokers.add(joker)

func buy_consumable(consumable):
	sever_shop_connections(consumable)
	consumables.add(consumable)

func buy_playing_card(card):
	sever_shop_connections(card)
	deck.add_card(card.data)

func buy_voucher(voucher: Area2D):
	voucher.data.use()
	vouchers.erase(voucher)
	voucher.queue_free()
	
	reset_shop()

# for changes to the shop on voucher buy (overstock etc)
func reset_shop():
	
	# OVERSTOCK SHOP RESET	
	if ((MAIN_STANDARD_SIZE + VoucherCardData.extra_shop_slots - main_size) > 0):
		cards_remaining = MAIN_STANDARD_SIZE + VoucherCardData.extra_shop_slots
		var offsets = get_card_x_offsets(cards_remaining)
	
		for i in range(cards_remaining - main.size()):
			get_main_card(0)
	
		for i in range(main.size()):
			main[i].position.x = offsets[1] + (i*offsets[0])
		
		setup_connections()
	
	# SHOP MONEY DECREASE TODO
	for card in main:
		card.update_cost()
	for booster in boosters:
		booster.update_cost()
	
	# REROLL VOUCHERS
	update_reroll_display()

func open_booster(booster):
	boosters.erase(booster)
	booster.queue_free()
	
	in_booster = true
	set_pack_background()
	
	match booster.data.booster_type:
		CardManager.BoosterType.arcana:
			open_pack(booster.data.booster_size, 3, 5, 
				ConsumableCardData, ConsumableCardData.ConsumableType.tarot
			)
		CardManager.BoosterType.celestial:
			open_pack(booster.data.booster_size, 3, 5, 
				ConsumableCardData, ConsumableCardData.ConsumableType.planet
			)
		CardManager.BoosterType.buffoon:
			open_pack(booster.data.booster_size, 2, 4, JokerCardData)
		CardManager.BoosterType.spectral:
			open_pack(booster.data.booster_size, 2, 4, 
				ConsumableCardData, ConsumableCardData.ConsumableType.spectral
			)
		CardManager.BoosterType.standard:
			open_pack(booster.data.booster_size, 2, 4, PlayingCardData)
	
	setup_booster_connections()	

func close_booster():
	if (in_booster):
		in_booster = false
		set_pack_background()
		
		for card in booster_cards:
			card.queue_free()
		booster_cards.clear()

func open_pack(size: CardManager.BoosterSize,
					min_size: int, max_size: int,
					data_class: Variant,
					extra_para = null):
	
	var count = min_size
	in_booster_count = 1
	
	if (size == CardManager.BoosterSize.jumbo):
		count = max_size
	elif (size == CardManager.BoosterSize.mega):
		count = max_size
		in_booster_count = 2
	
	var x_offset = -20
	if (count == 2):
		x_offset = 0
	elif (count == 3):
		x_offset = -10
	elif (count == 4):
		x_offset = -15
	
	for i in range(count):
		var card = CARD.instantiate()
		add_child(card)
		
		if (extra_para):
			card.setup(data_class.new(extra_para))
		else:
			card.setup(data_class.new())
		booster_cards.append(card)
		
		# create a card info, hide top cost
		card.data.set_shop_card()
		card.position = Vector2((x_offset), 5)		
		card.display_cost()
		card.card_buttons.switch_label(1)
		card.hide_cost_only()
		card.hide_use_only()
		
		if (data_class == JokerCardData):
			card.data.update_variable(jokers.get_joker_score_state())
		
		x_offset += 13


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


func update_reroll_display():
	var digits = Globals.convert_to_digits(
					game.get_reroll_cost(), 3, 999)
	
	RerollCostOnes.frame = digits[0]
	RerollCostTens.frame = digits[1]
	RerollCostOnes.frame = digits[2]

func update_buy_labels():
	for card in main:
		if (card.card_buttons):
			if (card.card_buttons.card_cost > game.money or 
				(card.data.is_joker() and 
				jokers.is_full())):
				card.card_buttons.disable()
			else:
				card.card_buttons.enable()
	
	for card in boosters:
		if (card.card_buttons):
			if (card.card_buttons.card_cost > game.money):
				card.card_buttons.disable()
			else:
				card.card_buttons.enable()
	
	for card in vouchers:
		if (card.card_buttons):
			if (card.card_buttons.card_cost > game.money):
				card.card_buttons.disable()
			else:
				card.card_buttons.enable()
				
func _on_reroll_button_pressed() -> void:
	if MouseManager.is_disabled:
		return
	
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
	if MouseManager.is_disabled:
		return
	
	if (in_booster):
		close_booster()
