extends Node2D

@export var digit_frames: SpriteFrames

var pos: Vector2i
var size: Vector2i
var col: Color

const connective_frames = preload("res://resources/connectives.tres")

var sprites = []

func _init(desc_data: Dictionary):
	size = Vector2i(13+15, 15)
	pos = Vector2i(-size.x+12, -1)
	self.z_index -= 1
	
	var width = generate_content(desc_data)
	rearrange_sprites(width)
	
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

# returns the width of the required box
func generate_content(desc_data: Dictionary) -> float:
	var max_len = 0 # pos.x+3.5
	var offset = Vector2(0.5, 3.5)

	# TOP SECTION
	match desc_data.benefit:
		JokerManager.Benefit.achips:
			pass
		
		JokerManager.Benefit.amult:
			var add = Globals.create_digit_sprite(10, offset)
			add_child(add)
			sprites.append(add)
			add.modulate = Globals.RED
			
			offset = do_digits(desc_data.benefit_val, offset, Globals.RED)
	
	max_len = offset.x
	
	# LOWER SECTION
	offset = Vector2(0, 9.5)
	match desc_data.connective:
		JokerManager.Connective.none:
			return max_len
		JokerManager.Connective.when_scored:
			var score_sym = create_symbol_sprite(0, offset)
			add_child(score_sym)
			score_sym.modulate = Globals.BLACK
			offset.x += 4
			
			var colon_sym = create_symbol_sprite(6, offset)
			add_child(colon_sym)
			colon_sym.modulate = Globals.BLACK
			sprites.append_array([score_sym, colon_sym])

	
	offset.x += 2
	match desc_data.condition:
		# suits
		JokerManager.Condition.spades:
			var sym = create_symbol_sprite(8, offset)
			add_child(sym)
			sprites.append(sym)
			
	
	if (offset.x > max_len):
		return offset.x
	return max_len
			

# currently using magic floaty numbers from spriteframe but i just want this online
func create_symbol_sprite(frame: int, offset: Vector2) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.frames = connective_frames
	sprite.position = offset
	sprite.z_index = 1
	sprite.frame = frame
	return sprite

func do_digits(value: int, offset: Vector2, colour) -> Vector2:
	var digits = str(value).split("")
	for digit in digits:
		if (int(digit) == 1):
			offset.x += 2
		else:
			offset.x += 4
		
		var sprite = Globals.create_digit_sprite(int(digit), offset)
		add_child(sprite)
		sprites.append(sprite)
		sprite.modulate = Globals.RED

	return offset

func rearrange_sprites(x_val):
	for sprite in sprites:
		sprite.position.x -= (x_val + 2)
		
