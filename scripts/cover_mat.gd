extends Sprite2D

@export var digit_frames: SpriteFrames
@export var full_deck: Texture2D
@export var remaining: Texture2D

@onready var deck = $"../../../Deck"
@onready var toggle_button = $ToggleButton
@onready var fade = $"../FadedBackground"

const WIDTH = 51 # 62-11 for size of guaranteed card
const CARD_START_POS = Vector2(36, -31)

var shown_digits = []
var shown_cards = []
var is_full_deck: bool = false

# for logic so dont need to recalc
var suit_counts = [0, 0, 0, 0]

func display(in_shop: bool):
	self.visible = true
	fade.visible = true
	
	clear_digits()
	clear_cards()
	
	# toggle setup
	if (in_shop):
		is_full_deck = true
		toggle_button.disabled = true
	else:
		is_full_deck = false
		toggle_button.disabled = false

	if (is_full_deck):
		toggle_button.texture_normal = full_deck
	else:
		toggle_button.texture_normal = remaining
	
	load_info()
	load_cards()
	disable_other_cards()

func disable_other_cards():
	MouseManager.disable(shown_cards)

func close():
	self.visible = false
	fade.visible = false
	MouseManager.enable()

func raise():
	self.position.y -= 4
	fade.position.y -= 4

func lower():
	self.position.y += 4
	fade.position.y += 4
	

func load_cards():
	var checkdeck = deck.get_checkdeck(is_full_deck)
	checkdeck.sort_custom(func(a, b):
		if  a.suit == b.suit:
			return a.rank < b.rank
		return a.suit < b.suit
	)
	for card in checkdeck:
		print(card.rank)
	
	var offset = CARD_START_POS
	var prev
	
	if (checkdeck.size() > 0):
		offset.x -= get_rank_offset(checkdeck[0].suit)
		prev = checkdeck[0]
	
	for i in range(checkdeck.size()):
		var card = create_card(checkdeck[i])
		
		# offset changes
		if prev.suit != checkdeck[i].suit:
			offset.y += 14
			offset.x = CARD_START_POS.x - get_rank_offset(checkdeck[i].suit)
		
		card.position = offset
		offset.x -= get_rank_spacing(checkdeck[i].suit)
		prev = checkdeck[i]
		shown_cards.append(card)

func get_rank_spacing(suit: int) -> int:
	if suit_counts[suit] > 1:
		return floor(WIDTH / (suit_counts[suit] - 1))
	return 0

func get_rank_offset(suit: int) -> int:
	if suit_counts[suit] > 1:
		return WIDTH % (suit_counts[suit] -1)
	return WIDTH / 2

func load_info():
	load_ranks()
	load_numbered()
	load_faces()
	load_suits()

func load_ranks():
	var offset = Vector2(-37.5, -22.5)
	var rank = 14
	for i in range(6):
		place_digit_sprites(deck.get_deck_count("rank", rank, is_full_deck), offset)
		offset.y += 6
		rank -= 1
	
	offset = Vector2(-22.5, -28.5)
	for i in range(7):
		place_digit_sprites(deck.get_deck_count("rank", rank, is_full_deck), offset)
		offset.y += 6
		rank -= 1

func load_numbered():
	var offset = Vector2(-37.5, 15.5)
	place_digit_sprites(deck.get_numbered_count(is_full_deck), offset)

func load_faces():
	var offset = Vector2(-22.5, 15.5)
	place_digit_sprites(deck.get_face_count(is_full_deck), offset)

func load_suits():
	var offset = Vector2(-37.5, 22.5)
	
	suit_counts[0] = deck.get_deck_count("suit", 0, is_full_deck)
	place_digit_sprites(suit_counts[0], offset)
	offset.y += 6
	suit_counts[2] = deck.get_deck_count("suit", 2, is_full_deck)
	place_digit_sprites(suit_counts[2], offset)
	offset.x += 15
	suit_counts[3] = deck.get_deck_count("suit", 3, is_full_deck)
	place_digit_sprites(suit_counts[3], offset)
	offset.y -= 6
	suit_counts[1] = deck.get_deck_count("suit", 1, is_full_deck)
	place_digit_sprites(suit_counts[1], offset)


func place_digit_sprites(value, offset: Vector2):
	var digits = Globals.convert_to_digits(value, 2, 99)
	var ones = Globals.create_digit_sprite(digits[1], Vector2(offset.x+4, offset.y))
	var tens = Globals.create_digit_sprite(digits[0], offset)
	
	add_child(ones)
	add_child(tens)
	shown_digits.append(ones)
	shown_digits.append(tens)

func create_card(data: CardData) -> Area2D:
	const CARD = preload("res://scenes/card.tscn")
	var card = CARD.instantiate()
	add_child(card)
	card.setup(data)
	return card

func clear_digits():
	for shown_digit in shown_digits:
		shown_digit.queue_free()
	shown_digits.clear()

func clear_cards():
	for shown_card in shown_cards.duplicate():
		shown_card.queue_free()
	shown_cards.clear()		


# toggle button logic
func _on_toggle_button_pressed() -> void:
	if (is_full_deck):
		is_full_deck = false
		toggle_button.texture_normal = remaining
	else:
		is_full_deck = true
		toggle_button.texture_normal = full_deck
	
	clear_digits()
	clear_cards()
	load_info()
	load_cards()

func _on_back_button_pressed() -> void:
	close()
