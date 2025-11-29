class_name CPUController
extends Node2D

@onready var cpu_hand: CPUHand = $"../CPUHand"
@onready var caravan: Caravan = $"../Caravan"

var pick_next_card := false # signal to pick next lowest card
var card_offset := 0 # offset if lowest card cannot fit inside a caravan

#still needs cpu turn to be called at end of player turn

# controls the cpu turn 
func cpu_turn():
	var card_picked = pick_card()
	pick_caravan(card_picked)


# picks the lowest card from the cpu hand 
func pick_card() -> Card:
	var cards: Array = []
	for i in range(cpu_hand.get_child_count()):
		cards.append(cpu_hand.get_child(i))
		# sort cards 
	cards.sort_custom(func(a, b): return a.value < b.value)
	# if first card, pick lowest 
	if !pick_next_card:
		return cards[0]
	# pick next lowest card in hand 
	var index = clamp(card_offset, 0, cards.size() - 1)
	return cards[index]


# attempts to find a caravan where the card picked can be placed 
func pick_caravan(card: Card):
	var placed := false
	# loop through caravans
	for c in $tract.get_children():
		if c.owned_by == "cpu":
			if card.check_placement_validity(c):
				c.add_card_to_cpu_caravan(card, c)
				placed = true
				break   # stop after card is placed
		# if no caravan valid try next card
		if !placed:
			pick_next_card = true
			pick_card()
