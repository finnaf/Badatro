extends Node2D

var digit_size = Vector2(3, 5)
@export var background_frames: SpriteFrames
@export var digit_frames: SpriteFrames

func set_value(is_plus, is_chips, score: int):
	clear_score()
	
	var digits = str(score).split("")
	var offset = Vector2(1.5, -5)
	do_background(is_chips, digits)
	
	if (digits.size() == 1):
		offset.x += 2

	var symbol
	if is_plus:
		symbol = create_sprite("10", offset)
	else:
		symbol = create_sprite("11", offset)
	
	if digits[0] == "1":
		offset.x += digit_size.x - 1
	else:
		offset.x += digit_size.x + 1
	add_child(symbol)
		
	
	for i in range(digits.size()):
		var digit = digits[i]
		if digit == "":
			continue
		
		if digits.size() > i+1:
			if digits[i] == "1":
				offset.x += digit_size.x - 2
		
		var sprite = create_sprite(digit, offset)
		add_child(sprite)
		offset.x += digit_size.x + 1

func create_sprite(value: String, offset: Vector2):
	var sprite = AnimatedSprite2D.new()
	sprite.frames = digit_frames
	sprite.frame = int(value)
	sprite.position = offset
	return sprite

func clear_score():
	for digit in get_children():
		digit.queue_free()

func do_background(is_chips: bool, digits):
	var len = digits.size()
	var background = AnimatedSprite2D.new()
	background.frames = background_frames
	if (is_chips):
		background.frame = 0
	else:
		background.frame = 1
	
	
	background.position += Vector2(6+(len), -5)
	add_child(background)
