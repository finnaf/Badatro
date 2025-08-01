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

func _init(desc_data: Dictionary):
	var width = generate_content(desc_data)
	
	size = Vector2i(13+width, 15)
	pos = Vector2i(-size.x+12, -1)
	self.z_index -= 1
	
	match desc_data.rarity:
		JokerManager.Rarity.common:
			col = Globals.BLUE
		JokerManager.Rarity.uncommon:
			col = Globals.DARKGREEN
		JokerManager.Rarity.rare:
			col = Globals.RED

func _draw():
	draw_rect(Rect2(pos, size), col)
	draw_rect(Rect2(Vector2(pos.x+1, pos.y+1), 
				Vector2(size.x-2, size.y-2)), Globals.WHITE)

func generate_content(desc_data: Dictionary) -> float:
	var top_y = 3.5
	var bot_y = 9.5
	var top_x = 0.0 # x axis
	var bot_x = 0.0
	var sprites : Array = []
	
	# TOP ROW
	var index = 0
	while true:
		var key = "benefit_%d" % index
		if desc_data.has(key):
			top_x = _do_benefit(desc_data, index, top_x, top_y, sprites)
		else:
			break
		index += 1
	
	
	
	
	# BOTTOM ROW
	match desc_data.connective:
		JokerManager.Connective.when_scored:
			bot_x = _place_symbol(0, DIGIT_SIZE, bot_x, bot_y, sprites, Globals.BLACK)
			bot_x = _place_symbol(10, SMALL_DIGIT_SIZE, bot_x, bot_y, sprites, Globals.BLACK)
		JokerManager.Connective.contains:
			bot_x = _place_symbol(1, DIGIT_SIZE, bot_x, bot_y, sprites, Globals.BLACK)
			bot_x = _place_symbol(10, SMALL_DIGIT_SIZE, bot_x, bot_y, sprites, Globals.BLACK)
		JokerManager.Connective.is_:
			bot_x = _place_symbol(2, DIGIT_SIZE, bot_x, bot_y, sprites, Globals.BLACK)
			bot_x = _place_symbol(10, SMALL_DIGIT_SIZE, bot_x, bot_y, sprites, Globals.BLACK)
		
		_:
			for s in sprites:
				s.position.x -= (top_x + 1)
				add_child(s)
			return (top_x + 1)
	
	index = 0
	while true:
		var key = "condition_%d" % index
		if desc_data.has(key):
			bot_x = _do_condition(desc_data[key], bot_x, bot_y, sprites)
		else:
			break
		index += 1

	var width = max(top_x, bot_x) + 1 # +1 for spacing from card

	for s in sprites:
		s.position.x -= width
		add_child(s)

	return width

func _do_benefit(data, i, top_x, top_y, sprites):
	var benefit = "benefit_%d" % i
	match data[benefit]:
		JokerManager.Benefit.addchips:
			top_x = _place_digit(10, top_x, top_y, sprites, Globals.BLUE)
		JokerManager.Benefit.addmult:
			top_x = _place_digit(10, top_x, top_y, sprites, Globals.RED)
		JokerManager.Benefit.xmult:
			top_x = _place_digit(11, top_x, top_y, sprites, Globals.RED)
		JokerManager.Benefit.chipnum:
			var ben_val = "benefit_val_%d" % i
			for d in str(data[ben_val]):
				top_x = _place_digit(int(d), top_x, top_y, sprites, Globals.BLUE)
		JokerManager.Benefit.multnum:
			var ben_val = "benefit_val_%d" % i
			var variable = data[ben_val]
			
			if (variable == int(variable)):
				data[ben_val] = int(variable)
			
			for d in str(data[ben_val]):
				top_x = _place_digit(int(d), top_x, top_y, sprites, Globals.RED)
		JokerManager.Benefit.to:
			top_x = _place_symbol(28, SMALL_DIGIT_SIZE+1, top_x, top_y, sprites, Globals.BLACK)
	
	return top_x

func is_float_int(val: float) -> bool:
	return val == int(val)
		
func _do_condition(cond, bot_x, bot_y, sprites):
	match cond:		
		JokerManager.Condition.spades:
			bot_x = _place_symbol(12, DIGIT_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.hearts:
			bot_x = _place_symbol(13, DIGIT_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.diamonds:
			bot_x = _place_symbol(14, DIGIT_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.clubs:
			bot_x = _place_symbol(15, DIGIT_SIZE, bot_x, bot_y, sprites)
	
		JokerManager.Condition.highcard:
			bot_x = _place_symbol(16, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.pair:
			bot_x = _place_symbol(17, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.twopair:
			bot_x = _place_symbol(18, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.threeofakind:
			bot_x = _place_symbol(19, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.straight:
			bot_x = _place_symbol(20, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.flush:
			bot_x = _place_symbol(21, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.fullhouse:
			bot_x = _place_symbol(22, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.fourofakind:
			bot_x = _place_symbol(23, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.straightflush:
			bot_x = _place_symbol(24, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.fiveofakind:
			bot_x = _place_symbol(25, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.flushhouse:
			bot_x = _place_symbol(26, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		JokerManager.Condition.flushfive:
			bot_x = _place_symbol(27, HAND_SYM_SIZE, bot_x, bot_y, sprites)
		
		JokerManager.Condition.cards:
			bot_x = _place_symbol(1, DIGIT_SIZE, bot_x, bot_y, sprites, Globals.BLACK)
		JokerManager.Condition.to:
			bot_x = _place_symbol(28, SMALL_DIGIT_SIZE+1, bot_x, bot_y, sprites, Globals.BLACK)
		
		# numbers (awful way to this)
		JokerManager.Condition.zero:
			bot_x = _place_digit(0, bot_x, bot_y, sprites, Globals.BLACK)
		JokerManager.Condition.two:
			bot_x = _place_digit(2, bot_x, bot_y, sprites, Globals.BLACK)
		JokerManager.Condition.three:
			bot_x = _place_digit(3, bot_x, bot_y, sprites, Globals.BLACK)
	return bot_x

func _place_symbol(frame: int, width: int, cursor: float, y: float,
							list: Array, colour = null) -> float:
	cursor += width * 0.5 # centre of sprite
	var s := Globals.create_symbol_sprite(frame, "default", Vector2(cursor + HALF, y))
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
