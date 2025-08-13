class_name ConsumableCardData
extends CardData

var consumable_type: ConsumableType

enum ConsumableType {
	none,
	planet,
	tarot,
	spectral,
}

enum Tarot {
	Fool,
	Magician,
	HighPriestess,
	Empress,
	Emperor,
	Hierophant,
	Lovers,
	Chariot,
	Justice,
	Hermit,
	WheelOfFortune,
	Strength,
	HangedMan,
	Death,
	Temperance,
	Devil,
	Tower,
	Star,
	Moon,
	Sun,
	Judgement,
	World
}

const planet_values = {
	"flush five": [50, 3],
	"flush house": [40, 4],
	"five of a kind": [35, 3],
	"straight flush": [40, 4],
	"four of a kind": [30, 3],
	"full house": [25, 2],
	"flush": [15, 2],
	"straight": [30, 3],
	"three of a kind": [20, 2],
	"two pair": [20, 1],
	"pair": [15, 1],
	"high card": [10, 1],
	"none": [0, 0]
}



func _init(type: ConsumableType):
	consumable_type = type
	
	if (consumable_type == ConsumableType.planet):
		id = randi_range(0, 11)
	elif (consumable_type == ConsumableType.tarot):
		id = randi_range(0, 21)

func get_cost() -> int:	
	var cost = 0
	
	if (consumable_type == ConsumableType.spectral):
		cost += 4
	else:
		cost += 3
				
	cost = floor(cost * VoucherCardData.discount_rate)
	if cost < 1:
		return 1
	return cost

func is_consumable() -> bool:
	return true
func is_planet() -> bool:
	if (consumable_type == ConsumableType.planet):
		return true
	return false
func is_tarot() -> bool:
	if (consumable_type == ConsumableType.tarot):
		return true
	return false

static func can_use(selected_cards: Array, consumable: Node) -> bool:
	if (consumable.data.is_planet()):
		return true
	
	return false

static func get_planet_name(value: int) -> String:
	match value:
		0:
			return "high card"
		1:
			return "pair"
		2:
			return "two pair"
		3:
			return "three of a kind"
		4:
			return "straight"
		5:
			return "flush"
		6:
			return "full house"
		7:
			return "four of a kind"
		8:
			return "straight flush"
		9:
			return "five of a kind"
		10:
			return "flush house"
		11:
			return "flush five"
		_:
			return "none"
