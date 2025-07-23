extends Node

enum Suit {
	spades,
	hearts,
	clubs,
	diamonds
}

enum Enhancement {
	none,
	bonus,
	mult,
	wild,
	glass,
	steel,
	stone,
	gold,
	lucky
}

enum Seal {
	none,
	red,
	blue,
	gold,
	purple
}

enum Edition {
	none,
	foil,
	holographic,
	polychrome,
	negative
}

enum CardType {
	none,
	card,
	joker,
	booster,
	voucher,
	consumable
}

enum BoosterType {
	buffoon,
	arcana,
	celestial,
	spectral,
	standard,
}

enum BoosterSize {
	normal,
	jumbo,
	mega
}

enum ConsumableType {
	none,
	planet,
	arcana,
	spectral,
}

var base_values = {
	"flush five": [160, 16],
	"flush house": [140, 14],
	"five of a kind": [120, 12],
	"straight flush": [100, 8],
	"four of a kind": [60, 7],
	"full house": [40, 4],
	"flush": [35, 4],
	"straight": [30, 4],
	"three of a kind": [30, 3],
	"two pair": [20, 2],
	"pair": [10, 2],
	"high card": [5, 1],
	"none": [0, 0]
}

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

func get_card_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	else:
		push_error("Card Texture " + path + " not found.")
		return null


func calculate_hand(hand: Array):
	if hand.is_empty():
		return "none"
	if is_flush(hand) and is_five_of_a_kind(hand):
		return "flush five"
	if is_full_house(hand) and is_flush(hand):
		return "flush house"
	if is_five_of_a_kind(hand):
		return "five of a kind"
	if is_straight(hand) and is_flush(hand):
		if is_royal_flush(hand):
			return "royal flush"
		return "straight flush"
	if is_four_of_a_kind(hand):
		return "four of a kind"
	if is_full_house(hand):
		return "full house"
	if is_flush(hand):
		return "flush"
	if is_straight(hand):
		return "straight"
	if is_three_of_a_kind(hand):
		return "three of a kind"
	if is_two_pair(hand):
		return "two pair"
	if is_pair(hand):
		return "pair"
	return "high card"

func is_five_of_a_kind(hand: Array):
	if hand.size() != 5:
		return false
	
	var rank = hand[0].get_rank()
	for card in hand:
		if card.get_rank() != rank:
			return false
	return true

func is_royal_flush(hand: Array):
	hand.sort_custom(func(a, b):
		return a["data"]["rank"] < b["data"]["rank"]
	)
		
	if hand[0].get_rank() == 10:
		return true
	return false

func is_four_of_a_kind(hand: Array):
	if four_of_a_kind_value(hand) == -1:
		return false
	return true

func is_full_house(hand: Array):
	var three = three_of_a_kind_value(hand)
	if three == -1:
		return false
	
	for acard in hand:
		for bcard in hand:
			if (acard.get_id() != bcard.get_id() and 
				acard.get_rank() == bcard.get_rank() and 
				acard.get_rank() != three):
				return true
	return false

func is_flush(hand: Array):
	if hand.size() != 5:
		return false

	var suit = hand[0].get_suit()
	for card in hand:
		if card.get_suit() != suit:
			return false
	return true

func is_straight(hand: Array):	
	if hand.size() != 5:
		return false
	
	hand.sort_custom(func(a, b):
		return a.get_rank() < b.get_rank()
	)
	
	# low aces
	if hand[4].get_rank() == 14 and hand[0].get_rank() == 2:
		if hand[1].get_rank() == 3 and hand[2].get_rank() == 4 and hand[3].get_rank() == 5:
			return true
	
	var check = hand[0].get_rank()
	for i in range(1, hand.size()):
		var rank = hand[i].get_rank()
		if rank != check + 1:
			return false
		check = rank
	return true

func is_three_of_a_kind(hand: Array):
	if three_of_a_kind_value(hand) == -1:
		return false
	return true

func is_two_pair(hand: Array):
	var pairs = two_pair_value(hand)
	if pairs[0] == -1 or pairs[1] == -1:
		return false
	return true

func is_pair(hand: Array):
	if pair_value(hand) == -1:
		return false
	return true
	
func three_of_a_kind_value(hand: Array) -> int:
	var rank_counts = {}

	for card in hand:
		var rank = card.get_rank()
		if not rank_counts.has(rank):
			rank_counts[rank] = 1
		else:
			rank_counts[rank] += 1

	for rank in rank_counts:
		if rank_counts[rank] >= 3:
			return rank
	return -1


func four_of_a_kind_value(hand: Array):
	if hand.size() < 4:
		return -1

	var acard = hand[0].get_rank()
	var bcard = hand[1].get_rank()
	var ccard = hand[2].get_rank()
	var check = -1
	var count = 0
	
	if (acard == bcard or acard == ccard):
		check = acard
		count += 2
	if (bcard == ccard):
		check = bcard
		if count == 2:
			count += 1
		else:
			count += 2
	
	if check == -1:
		return -1
	
	if hand[3].get_rank() == check:
		return check
	if hand.size() > 4:
		if hand[4].get_rank() == check:
			return check
	return -1

func two_pair_value(hand: Array):
	var pair
	for acard in hand:
		for bcard in hand:
			if (acard.get_id() != bcard.get_id() and 
				acard.get_rank() == bcard.get_rank()):
				pair = acard.get_rank()
				break
	for acard in hand:
		for bcard in hand:
			if (acard.get_id() != bcard.get_id() and 
				acard.get_rank() == bcard.get_rank() and 
				acard.get_rank() != pair):
				return [pair, acard.get_rank()]
	return [-1, -1]

func pair_value(hand: Array):
	for acard in hand:
		for bcard in hand:
			if (acard.get_id() != bcard.get_id() and 
				acard.get_rank() == bcard.get_rank()):
				return acard.get_rank()
	return -1


func convert_rank_to_chipvalue(rank: int) -> int:
	if rank <= 10:
		return rank
	if rank <= 13:
		return 10
	if rank == 14:
		return 11
	return -1

# returns value of enhancement chips, mult, xmult, money
func get_enhancement_val(card) -> Dictionary:
	match card.data.enhancement:
		Enhancement.bonus:
			return {"chips": 30}
		Enhancement.mult:
			return {"mult": 4}
		Enhancement.glass:
			return {"xmult": 2}
		Enhancement.stone:
			return {"chips": 50}
		Enhancement.lucky:
			# TODO chance
			# and things like trigger lucky cat
			return {"mult": 20, "money": 20}
		_:
			return {}

func get_edition_val(card):
	match card.data.edition:
		Edition.foil:
			return {"chips": 50}
		Edition.holographic:
			return {"mult": 10}
		Edition.polychrome:
			return {"xmult": 1.5}
		_:
			return {}
		

# kinda a stupid way of doing it, but need to calculate which of the cards
# are the ones that fulfill the hand
func get_active_cards(cards, hand):
	var need_five = ["flush five", "flush house", "five of a kind", "royal flush",
					"straight flush", "full house", "straight", "flush"]
	if hand in need_five:
		return cards
	
	var active_cards = []
	if hand == "four of a kind":
		var value = four_of_a_kind_value(cards)
		for card in cards:
			if card.get_rank() == value:
				active_cards.append(card)
	
	elif hand == "three of a kind":
		var value = three_of_a_kind_value(cards)
		for card in cards:
			if card.get_rank() == value:
				active_cards.append(card)
	
	elif hand == "two pair":
		var value = two_pair_value(cards)
		for card in cards:
			if card.get_rank() in value:
				active_cards.append(card)
	
	elif hand == "pair":
		var value = pair_value(cards)
		for card in cards:
			if card.get_rank() == value:
				active_cards.append(card)
	
	else: # must be a high card
		cards.sort_custom(func(a, b):
			return a["data"]["rank"] < b["data"]["rank"]
		)
		active_cards.append(cards[cards.size()-1])
	
	return active_cards

func get_card_cost(data: Dictionary) -> int:
	# TODO consumables
	
	var cost = 0
	if (data.type == CardType.joker):
		cost = JokerManager.get_joker(data.id).cost
		
	if (data.type == CardType.booster):
		if (data.booster_size == BoosterSize.normal):
			cost += 4
		elif (data.booster_size == BoosterSize.jumbo):
			cost += 6
		else: # mega
			cost += 8
		
	if (data.has("edition")):
		if (data.edition == Edition.foil):
			cost += 2
		elif (data.edition == Edition.holographic):
			cost += 3
		elif (data.edition == Edition.polychrome or
			data.edition == Edition.negative):
			cost += 5
	
	return cost

func get_suit_name(value: int) -> String:
	for name in Suit:
		if Suit[name] == value:
			return name
	return "none"
