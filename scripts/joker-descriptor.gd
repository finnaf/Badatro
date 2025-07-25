extends Node2D

# recalculates every times it is hovered over

@export var digit_frames: SpriteFrames

const DIGIT_SIZE = 4
const SMALL_DIGIT_SIZE = 2
const HAND_SYM_SIZE = 6
const HALF = 0.5

var pos: Vector2i
var size: Vector2i
var col: Color

const symbol_frames = preload("res://resources/symbols.tres")

func _init(desc_data: Dictionary):
	var width = generate_content(desc_data)
	
	size = Vector2i(13+width, 15)
	pos = Vector2i(-size.x+12, -1)
	self.z_index -= 1
	
	match desc_data.rarity:
		JokerManager.Rarity.common:
			col = Globals.GREY
		JokerManager.Rarity.uncommon:
			col = Globals.BLUE
		JokerManager.Rarity.rare:
			col = Globals.RED

func _draw():
	draw_rect(Rect2(pos, size), col)
	draw_rect(Rect2(Vector2(pos.x+1, pos.y+1), 
				Vector2(size.x-2, size.y-2)), Globals.WHITE)



func generate_content(desc_data: Dictionary) -> float:
	var top_y = 3.5
	var bot_y = 9.5
	var top_cursor = 0.0 # x axis
	var bot_cursor = 0.0
	var sprites : Array = []
	
	# TOP ROW
	match desc_data.benefit:
		JokerManager.Benefit.achips:
			top_cursor = _place_symbol(10, DIGIT_SIZE, top_cursor, top_y, sprites, Globals.BLUE)
			for d in str(desc_data.benefit_val):
				top_cursor = _place_digit(int(d), top_cursor, top_y, sprites, Globals.BLUE)
		JokerManager.Benefit.amult:
			top_cursor = _place_symbol(10, DIGIT_SIZE, top_cursor, top_y, sprites, Globals.RED)
			for d in str(desc_data.benefit_val):
				top_cursor = _place_digit(int(d), top_cursor, top_y, sprites, Globals.RED)
		JokerManager.Benefit.achipsmult:
			top_cursor = _place_symbol(10, DIGIT_SIZE, top_cursor, top_y, sprites, Globals.BLUE)
			for d in str(desc_data.benefit_val):
				top_cursor = _place_digit(int(d), top_cursor, top_y, sprites, Globals.BLUE)
			top_cursor = _place_symbol(10, DIGIT_SIZE, top_cursor, top_y, sprites, Globals.RED)
			for d in str(desc_data.benefit_val):
				top_cursor = _place_digit(int(d), top_cursor, top_y, sprites, Globals.RED)
		JokerManager.Benefit.xmult:
			top_cursor = _place_symbol(11, DIGIT_SIZE, top_cursor, top_y, sprites, Globals.RED)
			for d in str(desc_data.benefit_val):
				top_cursor = _place_digit(int(d), top_cursor, top_y, sprites, Globals.RED)
	
	
	# BOTTOM ROW
	match desc_data.connective:
		JokerManager.Connective.when_scored:
			bot_cursor = _place_symbol(0, DIGIT_SIZE, bot_cursor, bot_y, sprites, Globals.BLACK)
			bot_cursor = _place_symbol(6, SMALL_DIGIT_SIZE, bot_cursor, bot_y, sprites, Globals.BLACK)
		JokerManager.Connective.contains:
			bot_cursor = _place_symbol(1, DIGIT_SIZE, bot_cursor, bot_y, sprites, Globals.BLACK)
			bot_cursor = _place_symbol(6, SMALL_DIGIT_SIZE, bot_cursor, bot_y, sprites, Globals.BLACK)
		
		_:
			for s in sprites:
				s.position.x -= (top_cursor + 1)
				add_child(s)
			return (top_cursor + 1)

	match desc_data.condition:
		JokerManager.Condition.spades:
			bot_cursor = _place_symbol(8, DIGIT_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.hearts:
			bot_cursor = _place_symbol(9, DIGIT_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.diamonds:
			bot_cursor = _place_symbol(10, DIGIT_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.clubs:
			bot_cursor = _place_symbol(11, DIGIT_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.highcard:
			bot_cursor = _place_symbol(12, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.pair:
			bot_cursor = _place_symbol(13, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.twopair:
			bot_cursor = _place_symbol(14, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.threeofakind:
			bot_cursor = _place_symbol(15, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.straight:
			bot_cursor = _place_symbol(16, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.flush:
			bot_cursor = _place_symbol(17, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.fullhouse:
			bot_cursor = _place_symbol(18, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.fourofakind:
			bot_cursor = _place_symbol(19, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.straightflush:
			bot_cursor = _place_symbol(20, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.fiveofakind:
			bot_cursor = _place_symbol(21, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.flushhouse:
			bot_cursor = _place_symbol(22, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)
		JokerManager.Condition.flushfive:
			bot_cursor = _place_symbol(23, HAND_SYM_SIZE, bot_cursor, bot_y, sprites)

	var width = max(top_cursor, bot_cursor) + 1 # +1 for spacing from card

	for s in sprites:
		s.position.x -= width
		add_child(s)

	return width		

# currently using magic floaty numbers from spriteframe but i just want this online
func create_symbol_sprite(frame: int, offset: Vector2) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.frames = symbol_frames
	sprite.position = offset
	sprite.z_index = 1
	sprite.frame = frame
	return sprite

func _place_symbol(frame: int, width: int, cursor: float, y: float,
							list: Array, colour = null) -> float:
	cursor += width * 0.5 # centre of sprite
	var s := create_symbol_sprite(frame, Vector2(cursor + HALF, y))
	if (colour != null):
		s.modulate = colour
	list.append(s)
	cursor += width * 0.5 # step to right edge
	return cursor

func _place_digit(digit: int, cursor: float, y: float,
				 list: Array, colour: Color) -> float:
	
	var w = SMALL_DIGIT_SIZE if digit == 1 else DIGIT_SIZE
	cursor += w * 0.5
	var s := Globals.create_digit_sprite(digit, Vector2(cursor + HALF, y))
	if (digit == 1):
		s.position.x -= 1
	
	s.modulate = colour
	list.append(s)
	cursor += w * 0.5
	return cursor
