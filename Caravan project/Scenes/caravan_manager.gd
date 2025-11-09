extends Node2D

var caravans = []             # each caravan is an array of cards
var caravan_direction = []    # "ascending" or "descending"
var caravan_suit = []         # current suit enforced by Queens

func _ready() -> void:
	for i in range(3):
		caravans.append([])
		caravan_direction.append("") # direction not set until 2nd card
		caravan_suit.append("")      # suit not set until Queen played
	$PlayerCaravanSlot0.set_meta("caravan_index", 0)
	$PlayerCaravanSlot1.set_meta("caravan_index", 1)
	$PlayerCaravanSlot2.set_meta("caravan_index", 2)

func play_card(card, slot) -> bool:
	var caravan_index = slot.get_meta("caravan_index")
	var caravan = caravans[caravan_index]

	if not is_play_legal(card, caravan_index):
		return false

	if card.card_type == 0:
		caravan.append(card)
		# establish direction if this is the 2nd card
		if caravan.size() == 2:
			var diff = caravan[1].value - caravan[0].value
			if diff > 0:
				caravan_direction[caravan_index] = "ascending"
			elif diff < 0:
				caravan_direction[caravan_index] = "descending"
		update_caravan_state(caravan_index)
	else:
		apply_face_card(card, caravan_index)

	return true

func is_play_legal(card, caravan_index: int) -> bool:
	var caravan = caravans[caravan_index]
	if card.card_type == 0:
		if caravan.size() == 0:
			return true
		var last_card = caravan[-1]

		# enforce Queen suit if set
		if caravan_suit[caravan_index] != "" and card.suit != caravan_suit[caravan_index]:
			return false

		# enforce direction if set
		if caravan_direction[caravan_index] == "ascending" and card.value <= last_card.value:
			return false
		if caravan_direction[caravan_index] == "descending" and card.value >= last_card.value:
			return false

		# allow if ±1 or same suit
		var diff = card.value - last_card.value
		if abs(diff) == 1 or card.suit == last_card.suit:
			return true
		return false
	else:
		if caravan.size() == 0:
			return false
		var target = caravan[-1]
		# face cards only valid on Aces or number cards
		return target.card_type == 0

func apply_face_card(card, caravan_index: int) -> void:
	var caravan = caravans[caravan_index]
	var target = caravan[-1]

	match card.name.to_lower():
		"joker":
			if target.value == 1: # Ace
				remove_suit_from_table(target.suit, target)
			else:
				remove_value_from_table(target.value, target)
		"jack":
			remove_card_and_attached(target, caravan_index)
		"queen":
			caravan_direction[caravan_index] = reverse_direction(caravan_direction[caravan_index])
			caravan_suit[caravan_index] = card.suit
		"king":
			target.value *= 2
			update_caravan_state(caravan_index)

func remove_suit_from_table(suit: String, except_card):
	for caravan in caravans:
		for c in caravan.duplicate():
			if c.suit == suit and c != except_card and c.card_type == 0:
				caravan.erase(c)

func remove_value_from_table(value: int, except_card):
	for caravan in caravans:
		for c in caravan.duplicate():
			if c.value == value and c != except_card and c.card_type == 0:
				caravan.erase(c)

func remove_card_and_attached(card, caravan_index: int):
	var caravan = caravans[caravan_index]
	var idx = caravan.find(card)
	if idx != -1:
		caravan.resize(idx) # chop off card and everything after

func reverse_direction(dir: String) -> String:
	if dir == "ascending":
		return "descending"
	elif dir == "descending":
		return "ascending"
	else:
		return "" # not yet set

func update_caravan_state(caravan_index: int) -> void:
	var caravan = caravans[caravan_index]
	var total = 0
	for c in caravan:
		total += c.value
	print("Caravan %d total: %d" % [caravan_index, total])
	if total >= 21 and total <= 26:
		print("Caravan %d is sold!" % caravan_index)
