class_name JokerCardData
extends CardData

var is_flipped: bool = false

var rarity: JokerManager.Rarity
var variable: int = -1

func _init():	
	var rng = JokerManager.get_rng()
	generate_joker(rng)
	roll_edition(1, true, rng)

func generate_joker(rng: RandomNumberGenerator):
	var rarity_pick = rng.randf()
	if (rarity_pick > 0.95):
		rarity = JokerManager.Rarity.rare
		id = rng.randi_range(0, JokerManager.RareJokers.size()-1)
	elif (rarity_pick > 0.7):
		rarity = JokerManager.Rarity.uncommon
		id = rng.randi_range(0, JokerManager.UncommonJokers.size()-1)
	else:
		rarity = JokerManager.Rarity.common
		id = rng.randi_range(0, JokerManager.CommonJokers.size()-1)


func update_variable(state = null, scoreval = null):
	if (state == null):
		state = JokerManager.get_joker_score_state()
	
	if (scoreval == null):
		scoreval = JokerManager.get_score_val([], self, state)
	
	if (scoreval.has("eq_variable")):
		variable = scoreval.eq_variable
	elif (scoreval.has("add_variable")):
		variable += scoreval.add_variable

func get_rarity_string(rarity: JokerManager.Rarity) -> String:
	match rarity:
		JokerManager.Rarity.common:
			return "Common"
		JokerManager.Rarity.uncommon:
			return "Uncommon"
		JokerManager.Rarity.rare:
			return "Rare"
		JokerManager.Rarity.legendary:
			return "Legendary"
		_:
			return "Error"

func is_joker() -> bool:
	return true
