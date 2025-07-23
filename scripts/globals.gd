extends Node

var digit_frames

const YELLOW = Color(1, 0.7, 0.1)
const RED = Color(0.929, 0.11, 0.141)
const BLUE = Color(0.0, 0.650, 0.91)
const WHITE = Color(1.0,1.0,1.0)

enum ResourceType {
	chips,
	mult,
	xmult,
	money,
}

func _ready():
	digit_frames = load("res://resources/number-sprite-frames.tres")

func convert_to_digits(number, length, max) -> Array:
	if number > max:
		number = max
	if number < 0:
		number = 0
	
	var chars = str(number).pad_zeros(length).split("")
	var digits = []
	for c in chars:
		digits.append(int(c))
	return digits

func do_score_alert(card, is_plus: bool, is_chips: bool,
					value, speed, offset: int):
	const SCORE_ALERT = preload("res://scenes/score_alert.tscn")
	var score_alert = SCORE_ALERT.instantiate()
	score_alert.set_value(is_plus, is_chips, value)
	score_alert.position.y += (offset - 0.5)
	card.add_child(score_alert)
	return score_alert

func create_digit_sprite(value: int, offset: Vector2):
	var sprite = AnimatedSprite2D.new()
	sprite.frames = digit_frames
	sprite.frame = value
	sprite.position = offset
	sprite.z_index = 1
	return sprite
