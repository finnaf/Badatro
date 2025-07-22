extends VBoxContainer

@onready var game = $"../.."

@onready var moneygoalones = $MoneyGoal/MoneyGoalOnes
@onready var moneygoaltens = $MoneyGoal/MoneyGoalTens
@onready var moneygoalhundreds = $MoneyGoal/MoneyGoalHundreds
@onready var moneygoalthousands = $MoneyGoal/MoneyGoalThousands
@onready var moneygoaltenthousands = $MoneyGoal/MoneyGoalTenThousands
@onready var moneygoalhundredthousands = $MoneyGoal/MoneyGoalHundredThousands
@onready var moneygoalmillions = $MoneyGoal/MoneyGoalMillions
@onready var moneygoaltenmillions = $MoneyGoal/MoneyGoalTenMillions

@onready var moneygoalgained = $MoneyGoal/MoneyGoalGainedOnes

@onready var moneyhands = $MoneyHands/MoneyHands
@onready var moneyhandsgained = $MoneyHands/MoneyHandsGainedOnes

func _ready():
	game.updateCashoutUI.connect(_update_cashout)
	
	moneygoalgained.modulate = Globals.YELLOW
	moneyhandsgained.modulate = Globals.YELLOW
	
	moneyhands.modulate = Color(0.0, 0.650, 0.91)

func _update_cashout(req: int):
	var digits = convert_to_digits(req, 8, 99999999)
	moneygoalones.frame = digits[7]
	moneygoaltens.frame = digits[6]
	moneygoalhundreds.frame = digits[5]
	moneygoalthousands.frame = digits[4]
	moneygoaltenthousands.frame = digits[3]
	moneygoalhundredthousands.frame = digits[2]
	moneygoalmillions.frame = digits[1]
	moneygoaltenmillions.frame = digits[0]
	
	moneygoalgained.frame = game.get_money_gained()
	
	moneyhands.frame = game.hands
	moneyhandsgained.frame = game.hands * 2

func convert_to_digits(number, length: int, max) -> Array:
	if number > max:
		number = max
	if number < 0:
		number = 0
	
	var chars = str(number).pad_zeros(length).split("")
	var digits = []
	for c in chars:
		digits.append(int(c))
	return digits
