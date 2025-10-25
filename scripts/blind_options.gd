extends Node2D

@onready var game = $"../.."
@onready var deck = $"../../Deck"

@onready var small_blind_outln = $SmallBlind/bg
@onready var big_blind_outln = $BigBlind/bg
@onready var boss_blind_outln = $BossBlind/bg

@onready var small_button = $SmallBlind/Select
@onready var big_button = $BigBlind/Select
@onready var boss_button = $BossBlind/Select

@onready var small_digits := [
	$SmallBlind/GoalOnes,
	$SmallBlind/GoalTens,
	$SmallBlind/GoalHundreds,
	$SmallBlind/GoalThousands,
	$SmallBlind/GoalTenThousands,
	$SmallBlind/GoalHundredThousands,
	$SmallBlind/GoalMillions,
	$SmallBlind/GoalTenMillions
]

@onready var big_digits := [
	$BigBlind/GoalOnes,
	$BigBlind/GoalTens,
	$BigBlind/GoalHundreds,
	$BigBlind/GoalThousands,
	$BigBlind/GoalTenThousands,
	$BigBlind/GoalHundredThousands,
	$BigBlind/GoalMillions,
	$BigBlind/GoalTenMillions
]

@onready var boss_digits := [
	$BossBlind/GoalOnes,
	$BossBlind/GoalTens,
	$BossBlind/GoalHundreds,
	$BossBlind/GoalThousands,
	$BossBlind/GoalTenThousands,
	$BossBlind/GoalHundredThousands,
	$BossBlind/GoalMillions,
	$BossBlind/GoalTenMillions
]

func _ready():
	colour_outlines()
	colour_numbers()

func open():
	self.visible = true
	
	if game.blind == 0:
		update_goals()
	
	match game.blind:
		0:
			small_button.disabled = false
			big_button.disabled = true
			boss_button.disabled = true
			return
		1:
			small_button.disabled = true
			big_button.disabled = false
			boss_button.disabled = true
			return
		2:
			small_button.disabled = true
			big_button.disabled = true
			boss_button.disabled = false
			return
		_:
			print("Logic failure in blind options")

func close():
	self.visible = false
	await game.start_round()
	deck.begin_round()


func colour_outlines():
	small_blind_outln.modulate = Globals.BLUE
	big_blind_outln.modulate = Globals.MUSTARD
	boss_blind_outln.modulate = Globals.RED


func colour_numbers():
	for digit in small_digits:
		digit.modulate = Globals.BLACK
	for digit in big_digits:
		digit.modulate = Globals.BLACK
	for digit in boss_digits:
		digit.modulate = Globals.BLACK

func update_goals():
	var digits = Globals.convert_to_digits(game.calculate_goal(), 8, 99999999)
	for i in range(8):
		small_digits[7-i].frame = digits[i]
	
	digits = Globals.convert_to_digits(game.calculate_goal(1), 8, 99999999)
	for i in range(8):
		big_digits[7-i].frame = digits[i]
	
	digits = Globals.convert_to_digits(game.calculate_goal(2), 8, 99999999)
	for i in range(8):
		boss_digits[7-i].frame = digits[i]
	
	var offset = Vector2(-22.5, 18.5)
	for i in range(3):
		var dollar = Globals.create_symbol_sprite(0, "extras", offset)
		add_child(dollar)
		offset.x += 4
	
	offset.x += 8
	for i in range(4):
		var dollar = Globals.create_symbol_sprite(0, "extras", offset)
		add_child(dollar)
		offset.x += 4
	
	offset.x += 7
	for i in range(5):
		var dollar = Globals.create_symbol_sprite(0, "extras", offset)
		add_child(dollar)
		offset.x += 3


func _on_small_select_pressed():
	close()
func _on_big_select_pressed():
	close()
func _on_boss_select_pressed():
	close()
