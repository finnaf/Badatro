class_name JokerCardData
extends CardData

# meta affecting jokers
static var debt_potential : int					# from credit card
static var free_rolls : int						# from chaos the clown
static var chance_multiplier : int				# oops all sixes

static var jok_rng = RandomNumberGenerator.new()

var is_flipped: bool = false

var rarity: JokerManager.Rarity
var variable: int = 0

var score_func: Callable = Callable()
var trigger_func: Callable = Callable()
var round_end_func: Callable = Callable()

static func _static_init():
	debt_potential = 0
	chance_multiplier = 1

static func set_seed(seed: int):
	jok_rng.seed = seed

func _init():	
	generate_joker()
	roll_edition(1, true, jok_rng)
	
func generate_joker():
	var rarity_pick = jok_rng.randf()
	if (rarity_pick > 0.95):
		generate_by_rarity(JokerManager.Rarity.rare)
	elif (rarity_pick > 0.7):
		generate_by_rarity(JokerManager.Rarity.uncommon)
	else:
		generate_by_rarity(JokerManager.Rarity.common)

func generate_by_rarity(rarity):
	var pool = JokerManager.jokers_by_rarity[rarity]
	if pool.is_empty():
		rarity = JokerManager.Rarity.common
		id = JokerManager.Jokers.Joker
		score_func = Callable(JokerManager, "score_joker")
		return
	
	id = pool[jok_rng.randi() % pool.size()]
	var data = JokerManager.joker_info[id]
	self.rarity = rarity
	score_func = data.get("score_func", Callable())
	trigger_func = data.get("trigger_func", Callable())
	round_end_func = data.get("round_end_func", Callable())

func activate_static_effect():
	var data = JokerManager.joker_info[id]
	if (data.has("debt_potential")):
		debt_potential += data.debt_potential
	if (data.has("free_roll")):
		free_rolls += data.free_roll

func deactivate_static_effect():
	var data = JokerManager.joker_info[id]
	if (data.has(debt_potential)):
		debt_potential -= data.debt_potential
	if (data.has("free_roll")):
		free_rolls -= data.free_roll

# gets the value of the joker when it is triggered
func get_score_val(state: Dictionary, active_cards = []) -> Dictionary:
	state.merge({"active_cards": active_cards})
	
	if score_func:
		return score_func.call(self, state)
	return {}

# gets the value of the joker from a specific card being triggered
func get_trigger_val(card: PlayingCardData) -> Dictionary:
	if trigger_func:
		return trigger_func.call(self, card)
	return {}

# TODO implement
func get_round_end_val() -> Dictionary:
	if round_end_func:
		return round_end_func.call(self)
	return {}

func update_variable(state: Dictionary, scoreval = null):	
	# simulate the joker being triggered to get value
	if (scoreval == null):
		scoreval = get_score_val(state)
	
	if (scoreval.has("eq_variable")):
		variable = scoreval.eq_variable
	elif (scoreval.has("add_variable")):
		variable += scoreval.add_variable
	

func get_cost() -> int:		
	var cost = JokerManager.joker_info[id].cost
	cost += get_edition_cost()
	
	cost = floori(cost * VoucherCardData.discount_rate)
	if cost < 1:
		return 1
	return cost

func is_joker() -> bool:
	return true

## helper function for all x in y function calls in jokers (for oops handling)
## counts from 1 inclusive, true if below or equal to threshold
static func do_dice_roll(thresh : int, max : int) -> bool:
	var val = CardData.get_rnd_int(1, max)
	
	if val <= thresh * chance_multiplier:
		return true
	return false
