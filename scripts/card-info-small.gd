extends Sprite2D

@export var digit_frames: SpriteFrames
@export var get_tex: Texture2D
@export var buy_tex: Texture2D
@onready var button: TextureButton = $Button

var card_cost

signal buy_clicked(card)

func _ready():
	self.position += Vector2(5, -4)
	$Button.pressed.connect(_on_pressed)

func switch_label(is_get: bool):
	if (is_get):
		hide_cost()
		button.texture_normal = get_tex
		display_button()
	else:
		show_cost()
		button.texture_normal = buy_tex
	

func _on_pressed():
	emit_signal("buy_clicked", self)

func set_value(cost: int, type: CardManager.CardType):
	clear_score()
	
	card_cost = cost
	var digits = str(cost).split("")
	
	var offset
	if (digits.size() == 2):
		if (digits[0] == "1"):
			offset = Vector2(-2.5, 0.5)
		else:
			offset = Vector2(-1.5, 0.5)
	elif (digits.size() == 1):
		offset = Vector2(0.5, 0.5)
	else:
		print("Invalid cost length.")
		return
		
	# as any pack is taller than a regular card
	if (type == CardManager.CardType.booster):
		self.position.y -= 1
		button.position.y += 2
	
	for i in range(digits.size()):
		var digit = digits[i]
		if digit == "":
			continue
		
		var sprite = create_sprite(digit, offset)
		sprite.modulate = Globals.YELLOW
		add_child(sprite)
		offset.x += 4

func clear_score():
	for digit in get_children():
		if digit != $Button:
			digit.queue_free()

func create_sprite(value: String, offset: Vector2):
	var sprite = AnimatedSprite2D.new()
	sprite.frames = digit_frames
	sprite.frame = int(value)
	sprite.position = offset
	return sprite

func hide_cost():
	clear_score()
	self.texture = null
func show_cost():
	set_value(card_cost, CardManager.CardType.joker)
	# cba, add background too
func display_button():
	button.visible = true
func hide_button():
	button.visible = false
func disable():
	button.disabled = true
func enable():
	button.disabled = false
