extends Sprite2D

@onready var game = $"../.."
@onready var deck = $"../../Deck"

@onready var discardbutton = $"../BottomButtons/DiscardButton"
@onready var playbutton = $"../BottomButtons/PlayButton"

@onready var ante = $Ante
@onready var discards = $Discards
@onready var hands = $Hands
@onready var moneyones = $MoneyOnes
@onready var moneytens = $MoneyTens
@onready var roundones = $RoundOnes
@onready var roundtens = $RoundTens
@onready var multones = $MultOnes
@onready var multtens = $MultTens
@onready var multhundreds = $MultHundreds
@onready var multthousands = $MultThousands
@onready var chipones = $ChipOnes
@onready var chiptens = $ChipTens
@onready var chiphundreds = $ChipHundreds
@onready var chipthousands = $ChipThousands
@onready var scoreones = $ScoreOnes
@onready var scoretens = $ScoreTens
@onready var scorehundreds = $ScoreHundreds
@onready var scorethousands = $ScoreThousands
@onready var scoretenthousands = $ScoreTenThousands
@onready var scorehundredthousands = $ScoreHundredThousands
@onready var scoremillions = $ScoreMillions
@onready var scoretenmillions = $ScoreTenMillions
@onready var goalones = $GoalOnes
@onready var goaltens = $GoalTens
@onready var goalhundreds = $GoalHundreds
@onready var goalthousands = $GoalThousands
@onready var goaltenthousands = $GoalTenThousands
@onready var goalhundredthousands = $GoalHundredThousands
@onready var goalmillions = $GoalMillions
@onready var goaltenmillions = $GoalTenMillions

func _ready():
	setup_values()
	
	deck.updateClickUI.connect(_update_click)
	deck.updateButtonsUI.connect(_update_buttons)
	game.updateScoreUI.connect(_update_score)
	game.updateGoalUI.connect(_update_goal)
	game.updateMoneyUI.connect(_update_money)

	# colouring
	roundones.modulate = Globals.MUSTARD
	roundtens.modulate = Globals.MUSTARD
	ante.modulate = Globals.BLACK
	
	_color_score_goal_black()
	
	moneytens.modulate = Globals.YELLOW
	moneyones.modulate = Globals.YELLOW
	
	discards.modulate = Globals.RED
	hands.modulate = Globals.BLUE
	
	chipthousands.frame = 1
	chipthousands.modulate = Globals.BLUE
	
	multthousands.frame = 1
	multthousands.modulate = Globals.RED

func _color_score_goal_black():
	scoreones.modulate = Globals.BLACK
	scoretens.modulate = Globals.BLACK
	scorehundreds.modulate = Globals.BLACK
	scorethousands.modulate = Globals.BLACK
	scoretenthousands.modulate = Globals.BLACK
	scorehundredthousands.modulate = Globals.BLACK
	scoremillions.modulate = Globals.BLACK
	scoretenmillions.modulate = Globals.BLACK
	
	goalones.modulate = Globals.BLACK
	goaltens.modulate = Globals.BLACK
	goalhundreds.modulate = Globals.BLACK
	goalthousands.modulate = Globals.BLACK
	goaltenthousands.modulate = Globals.BLACK
	goalhundredthousands.modulate = Globals.BLACK
	goalmillions.modulate = Globals.BLACK
	goaltenmillions.modulate = Globals.BLACK

func _on_play_button_pressed():
	discardbutton.disabled = true
	playbutton.disabled = true

func _update_money():
	update_money()

func _update_goal():
	update_goal()

func _update_score():
	update_score()

func _update_click():
	update_chips()
	update_mult()
	handle_button_state()
	

func setup_values():
	ante.frame = game.ante
	
	var digits = Globals.convert_to_digits(game.round, 2, 99)
	roundones.frame = digits[1]
	roundtens.frame = digits[0]
	
	_update_buttons()
	_update_click()

# activated at the end of any button press
func _update_buttons():
	discards.frame = game.discards
	hands.frame = game.hands
	
	if game.state == game.states.PLAYING:
		playbutton.disabled = false
		discardbutton.disabled = false
	elif game.state != game.states.PLAYING:
		playbutton.disabled = true
		discardbutton.disabled = true
	
	if not game.can_discard():
		discardbutton.disabled = true
	
	update_money()
	update_chips()
	update_mult()
	handle_button_state()
	
func update_chips():
	var digits = Globals.convert_to_digits(game.chips, 4, 1999)
	chipones.frame = digits[3]
	chiptens.frame = digits[2]
	chiphundreds.frame = digits[1]
	
	if digits[0] == 0:
		chipthousands.frame = 1
		chipthousands.modulate = Globals.BLUE
	else:
		chipthousands.frame = digits[0]
		chipthousands.modulate = Globals.WHITE

func update_mult():
	var digits = Globals.convert_to_digits(game.mult, 4, 1999)
	multones.frame = digits[3]
	multtens.frame = digits[2]
	multhundreds.frame = digits[1]
	
	if digits[0] == 0:
		multthousands.frame = 1
		multthousands.modulate = Globals.RED
	else:
		multthousands.frame = digits[0]
		multthousands.modulate = Globals.BLUE
		
func update_score():
	var digits = Globals.convert_to_digits(game.score, 8, 99999999)
	scoreones.frame = digits[7]
	scoretens.frame = digits[6]
	scorehundreds.frame = digits[5]
	scorethousands.frame = digits[4]
	scoretenthousands.frame = digits[3]
	scorehundredthousands.frame = digits[2]
	scoremillions.frame = digits[1]
	scoretenmillions.frame = digits[0]

func update_goal():
	var digits = Globals.convert_to_digits(game.calculate_goal(), 8, 99999999)
	goalones.frame = digits[7]
	goaltens.frame = digits[6]
	goalhundreds.frame = digits[5]
	goalthousands.frame = digits[4]
	goaltenthousands.frame = digits[3]
	goalhundredthousands.frame = digits[2]
	goalmillions.frame = digits[1]
	goaltenmillions.frame = digits[0]

func update_round():
	var digits = Globals.convert_to_digits(game.get_round(), 2, 99)
	roundones.frame = digits[1]
	roundtens.frame = digits[0]

func update_ante():
	var digits = Globals.convert_to_digits(game.get_ante(), 1, 9)
	ante.frame = digits[0]

func update_money():
	var digits = Globals.convert_to_digits(game.money, 2, 99)
	moneyones.frame = digits[1]
	moneytens.frame = digits[0]

func handle_button_state():
	# grey out the discard button when no cards are selected
	if deck.selected_cards.is_empty() or game.state != game.states.PLAYING:
		discardbutton.disabled = true
		playbutton.disabled = true
	else:
		if game.can_discard():
			discardbutton.disabled = false
		playbutton.disabled = false
