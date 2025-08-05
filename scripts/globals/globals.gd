extends Node

var digit_frames
const symbol_frames = preload("res://resources/symbols.tres")


# ENDESCA 32
const WHITE = Color("ffffff")
const GREY = Color("c0cbdc")
const BLACK = Color("181425")
const RED = Color("ff0044")
const BLUE = Color("0099db")
const YELLOW = Color("feae34") # money col

const GREEN = Color("3e8948") # mat/reroll col
const DARKGREEN = Color("265c42") # joker/consum area

const MUSTARD = Color("f77622") # diamonds, low importance text


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
