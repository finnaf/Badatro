extends Sprite2D

@onready var game = $"../.."

var jokers = []
var MAX_JOKERS = 5

# score the card for each joker, return values for animating
func score_card(card) -> Array:
	var joker_scores = []
	for joker in jokers:
		var vals = JokerManager.get_trigger_val(card, joker)
		if (not vals.is_empty()):
			joker_scores.append(vals)
	return joker_scores
		

# score each joker and do animating
func score_jokers(active_cards):
	for joker in jokers:		
		var editionval = CardManager.get_edition_val(joker)
		await game.add_resources(joker, editionval)
		
		# get a dictionary
		var scoreval = JokerManager.get_score_val(active_cards, joker, game.get_game_state())
		await game.add_resources(joker, scoreval)

func add(joker):
	jokers.append(joker)
	add_child(joker)
	joker.position = Vector2(0,-6)
	reorganise_jokers()

func reorganise_jokers():
	for i in range(jokers.size()):
		jokers[i].position.x = get_joker_position(i)

func is_full():
	if (jokers.size() < MAX_JOKERS):
		return false
	return true

func get_joker_position(i):
	var spacing = round((55)/jokers.size())
	var total_width = (jokers.size() - 1) * spacing
	return ((i * spacing) - (total_width/2)) - 5
