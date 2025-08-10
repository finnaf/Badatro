class_name JokerCardData
extends CardData

static var jok_rng = RandomNumberGenerator.new()

var is_flipped: bool = false

var rarity: JokerManager.Rarity
var variable: int = 0

var score_func: Callable = Callable()
var trigger_func: Callable = Callable()

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

	id = pool[jok_rng.randi() % pool.size()]
	var data = JokerManager.joker_info[id]
	score_func = data.get("score_func", Callable())
	trigger_func = data.get("trigger_func", Callable())

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

func update_variable(state: Dictionary, scoreval = null):	
	if (scoreval == null):
		scoreval = get_score_val(state)
	
	if (scoreval.has("eq_variable")):
		variable = scoreval.eq_variable
	elif (scoreval.has("add_variable")):
		variable += scoreval.add_variable


func get_cost(discount_percent: float) -> int:		
	var cost = JokerManager.joker_info[id].cost
	cost += get_edition_cost()
			
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_joker() -> bool:
	return true
