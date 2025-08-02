extends Node

var digit_frames
const symbol_frames = preload("res://resources/symbols.tres")

# OLD VALS
# const YELLOW = Color(1, 0.7, 0.1)
# const RED = Color(0.929, 0.11, 0.141)
# const BLUE = Color(0.0, 0.650, 0.91)
# const WHITE = Color(1.0,1.0,1.0)
# const BLACK = Color(0.0,0.0,0.0)
# const GREY = Color(0.498, 0.498, 0.498)
# const GREEN = Color(0.016, 0.478, 0.102)
# const DARKGREEN = Color(0.016, 0.376, 0.098)

const WHITE = Color("ffffff")
const GREY = Color("bfc7d5")
const BLACK = Color("4f6367")
const RED = Color("fd5f55")
const BLUE = Color("009cfd")
const YELLOW = Color("fda200")

const LIGHTGREEN = Color("74cca8")
const GREEN = Color("56a786")
const DARKGREEN = Color("459373")

const PINK = Color("ff9690")
const DEEPRED = Color("c14139")

const LIGHTBLUE = Color("3cb4ff")
const DARKBLUE = Color("008be3")

const DARKYELLOW = Color("ea9600")
const MUSTARD = Color("c88000")

const LIGHTBROWN = Color("b7a88a")
const DARKBROWN = Color("847f66")

enum ResourceType {
	chips,
	mult,
	xmult,
	money,
}

# TODO fix this error (why cant it be preloaded)
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

func create_digit_sprite(value: int, offset: Vector2) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.frames = digit_frames
	sprite.frame = value
	sprite.position = offset
	sprite.z_index = 1
	return sprite

func create_symbol_sprite(frame: int, ani, offset: Vector2) -> AnimatedSprite2D:
	var sprite = AnimatedSprite2D.new()
	sprite.frames = symbol_frames
	sprite.animation = ani
	sprite.position = offset
	sprite.z_index = 1
	sprite.frame = frame
	return sprite

func do_shake(node: Node, weight = 1.02):
	var shake_size = Vector2(weight, weight)
	var height_adjust = (((shake_size.y - 1) / 13) / 2)
	var width_adjust = (((shake_size.x - 1) / 11) / 2)
	
	node.scale = shake_size
	node.position -= Vector2(height_adjust, width_adjust)
	await get_tree().create_timer(0.1).timeout
	node.scale = Vector2.ONE
	node.position += Vector2(height_adjust, width_adjust)
