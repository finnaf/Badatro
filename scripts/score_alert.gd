extends Node2D

var digit_size = Vector2(3, 5)
@onready var background: Sprite2D = $Background
@export var digit_frames: SpriteFrames

func set_value(is_plus: bool, type: int, score: float):
	clear_score()
	var digits
	
	# set int values to ints
	if (score == int(score)):
		digits = str(int(score)).split("")
	else:
		digits = str(score).split("")
			
	var offset = Vector2(1.5, -5)
	do_background(type, digits)
	
	if (digits.size() == 1):
		offset.x += 2

	var symbol
	if is_plus:
		symbol = Globals.create_digit_sprite(10, offset)
	else:
		symbol = Globals.create_digit_sprite(11, offset)
	
	if digits[0] == "1":
		offset.x += digit_size.x - 1
	else:
		offset.x += digit_size.x + 1
	add_child(symbol)
		
	
	for i in range(digits.size()):
		var digit = digits[i]
		if digit == "":
			continue
		if digit == ".":
			offset.x -= 1
			var sprite = Globals.create_symbol_sprite(29, "default", offset)
			add_child(sprite)
			offset.x += 3
			continue
		
		if digits.size() > i+1:
			if digits[i] == "1":
				offset.x += digit_size.x - 2
		
		var sprite = Globals.create_digit_sprite(int(digit), offset)
		add_child(sprite)
		offset.x += digit_size.x + 1

func do_background(type: int, digits):
	var len = digits.size()

	match type:
		0: background.modulate = Globals.BLUE
		1: background.modulate = Globals.RED
		2: background.modulate = Globals.YELLOW

	background.position += Vector2(6 + len, -5)

func clear_score():
	for digit in get_children():
		if digit != background:
			digit.queue_free()
