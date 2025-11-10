class_name Hand
extends ColorRect

#const CARD = preload("res://Scenes/card.tscn")

@export var hand_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees := 5
@export var x_sep := -10 # seperation between cards on the x axis in pixels, negative values mean the cards will cram together, positive values mean space in between
@export var y_min := 0 # offset on the y-axis compared to the hand's position
@export var y_max := -15 # maximum amount of y offset that can be applied to cards based on the hand card

func add_card_to_hand(new_card):
	add_child(new_card)
	_update_cards()
	pass

# func _draw_card():
# 	var new_card = CARD.instantiate()
# 	add_child(new_card)
# 	_update_cards()

func _discard() -> void:
	if $"../Deck".deck.size() == 0:
		return

	if $"../Deck".deck.size() - 1 == 0:
		$"../discard_card_button".disabled = true
	
	if get_child_count() < 1: # no children means do not discard
		return

	var child := get_child(-1) # using the -1 index grabs the last child added to the hand
	child.reparent(get_tree().root) # reparenting means that we know for sure when we call update cards the card wont be a child of the hand anymore
	child.queue_free() # queue free only deletes a node at the end of the frame when its safe to do so
	
	$"../Deck".draw_card()	


func _update_cards():
	var cards := get_child_count()
	var all_cards_size := Card.SIZE.x * cards + x_sep * (cards - 1) # calculate the total size of these cards in pixels
	var final_x_sep := x_sep # final_x_sep allows for cards to overlap each other

	if all_cards_size > size.x: # are all of the cards overflowing the width of the hand?
		final_x_sep = (size.x - Card.SIZE.x * cards) / (cards - 1) # its fine to leave this as an integer
		all_cards_size = size.x

	var offset := (size.x - all_cards_size) / 2 # offset will be zero when cards overflow width of hand

	for i in cards: # loop 0 - # of cards - 1
		var card := get_child(i)
		var y_multipler := hand_curve.sample(1.0 / (cards-1) * i) # formula inside sample gives you the position of the card on the x-axis
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) * i)

		if cards == 1: # when you only have 1 card cards - 1 becomes 0, this sets the values manually 
			y_multipler = 0.0
			rot_multiplier = 0.0

		var final_x: float = offset + Card.SIZE.x * i + final_x_sep * i # mult the cards width by final x sep and add the offset to get final x pos
		var final_y: float = y_min + y_max * y_multipler # apply the y min offset, then the curve based y offset, and mult by percentage got from the curve

		card.position = Vector2(final_x, final_y)
		card.rotation_degrees = max_rotation_degrees * rot_multiplier
