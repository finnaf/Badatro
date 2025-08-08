class_name BoosterCardData
extends CardData

var booster_type: CardManager.BoosterType
var booster_size: CardManager.BoosterSize

# uses shop rng
func _init(rng: RandomNumberGenerator):
	
	const BOOSTER_WEIGHTS = [
		{ "type": "spectral", "size": 0, "weight": 0.6 },
		{ "type": "spectral", "size": 1, "weight": 0.3 },
		{ "type": "spectral", "size": 2, "weight": 0.07 },
	
		{ "type": "buffoon", "size": 0, "weight": 1.2 },
		{ "type": "buffoon", "size": 1, "weight": 0.6 },
		{ "type": "buffoon", "size": 2, "weight": 0.15 },
	
		{ "type": "standard", "size": 0, "weight": 4 },
		{ "type": "standard", "size": 1, "weight": 2 },
		{ "type": "standard", "size": 2, "weight": 0.5 },
		
		{ "type": "arcana", "size": 0, "weight": 4 },
		{ "type": "arcana", "size": 1, "weight": 2 },
		{ "type": "arcana", "size": 2, "weight": 0.5 },
		
		{ "type": "celestial", "size": 0, "weight": 4 },
		{ "type": "celestial", "size": 1, "weight": 2 },
		{ "type": "celestial", "size": 2, "weight": 0.5 },
	]
	
	var chosen = pick_weighted(rng, BOOSTER_WEIGHTS)
	match chosen.type:
		"spectral":
			booster_type = CardManager.BoosterType.spectral
		"buffoon":
			booster_type = CardManager.BoosterType.buffoon
		"standard":
			booster_type = CardManager.BoosterType.standard
		"arcana":
			booster_type = CardManager.BoosterType.standard
		"celestial":
			booster_type = CardManager.BoosterType.standard
	
	match chosen.size:
		0:
			booster_size = CardManager.BoosterSize.normal
		1:
			booster_size = CardManager.BoosterSize.jumbo
		2:
			booster_size = CardManager.BoosterSize.mega
	
	set_shop_card()

# AIed code to iterate through weights
func pick_weighted(rng: RandomNumberGenerator, options: Array) -> Dictionary:
	var total_weight = 0.0
	for option in options:
		total_weight += option.weight

	var threshold = rng.randf_range(0.0, total_weight)
	var running_total = 0.0

	for option in options:
		running_total += option.weight
		if threshold <= running_total:
			return option
	
	return options[-1]

func get_cost(discount_percent: float) -> int:	
	var cost = 0
	
	if (booster_size == CardManager.BoosterSize.normal):
		cost += 4
	elif (booster_size == CardManager.BoosterSize.jumbo):
		cost += 6
	else: # mega
		cost += 8
		
	cost += get_edition_cost()
			
	cost = floor(cost * discount_percent)
	if cost < 1:
		return 1
	return cost

func is_booster() -> bool:
	return true
