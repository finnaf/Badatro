extends Node2D

@export var digit_frames: SpriteFrames

var pos: Vector2i
var size: Vector2i
var col: Color

var sprites = []

func _init(desc_data: Dictionary):
	size = Vector2i(13+15, 15)
	pos = Vector2i(-size.x+12, -1)
	self.z_index -= 1
	generate_content(desc_data)
	
	match desc_data.rarity:
		JokerManager.Rarity.common:
			col = Globals.BLUE
		JokerManager.Rarity.common:
			col = Globals.BLUE
		JokerManager.Rarity.rare:
			col = Globals.RED

func _draw():
	draw_rect(Rect2(pos, size), col)
	draw_rect(Rect2(Vector2(pos.x+1, pos.y+1), 
				Vector2(size.x-2, size.y-2)), Globals.WHITE)
	
func generate_content(desc_data: Dictionary) -> Vector2i:
	var max_len = 0
	
	# TOP SECTION
	match desc_data.benefit:
		JokerManager.Benefit.achips:
			pass#
		
		JokerManager.Benefit.amult:
			var offset = Vector2(pos.x+3.5, 3.5)
			var add = Globals.create_digit_sprite(10, offset)
			add_child(add)
			sprites.append(add)
			add.modulate = Globals.RED
			
			offset = do_digits(desc_data.benefit_val, offset, Globals.RED)
	
	# there is a connective, so generate LOWER SECTION
	if (desc_data.connective != JokerManager.Connective.none):
		pass
	
	return Vector2(0,0)

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
