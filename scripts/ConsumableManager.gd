extends Node

var planet_values = {
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

# pass in card select state
func can_use(selected_cards: Array, consumable: Node) -> bool:
	
	if (consumable.is_planet()):
		return true
	
	return true


func get_planet_name(value: int) -> String:
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
			return "five of a kind"
		_:
			return "none"
