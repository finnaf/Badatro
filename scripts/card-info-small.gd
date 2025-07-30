extends Sprite2D

# has:
# cost
# use button
# buy / get / sell button

@export var digit_frames: SpriteFrames
@export var bg: Texture2D
@export var buy_tex: Texture2D
@export var get_tex: Texture2D
@export var sell_tex: Texture2D
@onready var button: TextureButton = $Button
@onready var use_button: TextureButton = $Use

var card_cost

var nums = []

signal button_clicked(card)
signal use_clicked(card)

func _ready():
	self.position += Vector2(5, -4)
	self.texture = bg
	button.pressed.connect(_on_pressed)
	use_button.pressed.connect(_on_use_pressed)
	use_button.modulate = Globals.YELLOW # always starts with a yellow use (costs money)
	
	hide_use()
	hide_button()

# 0 - buy, 1 - get, 2 - sell
func switch_label(button_type: int):
	if (button_type == 0):
		button.texture_normal = buy_tex
	elif (button_type == 1):
		button.texture_normal = get_tex	
	else:
		# needs to be below to be seen
		for digit in nums:
			digit.position.y += 20
		
		button.texture_normal = sell_tex
		self.texture = null

func switch_use_side():
	use_button.position.x -= 16
	use_button.modulate = Globals.WHITE

func _on_use_pressed():
	emit_signal("use_clicked", self)
func _on_pressed():
	emit_signal("button_clicked", self)

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
		nums.append(sprite)
		offset.x += 4

func clear_score():
	for digit in nums:
		digit.queue_free()
	nums.clear()

func create_sprite(value: String, offset: Vector2):
	var sprite = AnimatedSprite2D.new()
	sprite.frames = digit_frames
	sprite.frame = int(value)
	sprite.position = offset
	return sprite

# TOP LABEL
func hide_cost():
	clear_score()
	self.texture = null
func show_cost():
	self.texture = bg
	set_value(card_cost, CardManager.CardType.joker)

# BOTTOM LABEL
func hide_button():
	button.visible = false
func display_button():
	button.visible = true

# SIDE LABEL
func display_use():
	use_button.visible = true
func hide_use():
	use_button.visible = false
	
func disable():
	button.disabled = true
	use_button.disabled = true
func enable():
	button.disabled = false
	use_button.disabled = false
