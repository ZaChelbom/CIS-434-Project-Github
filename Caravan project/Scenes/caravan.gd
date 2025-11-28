class_name Caravan
extends Node2D

var owned_by: String # player or cpu

var caravan_value: int # the sum value of the caravan
var is_sold: bool
var caravan_suit: String # clubs, diamonds, hearts, spades
var caravan_direction: String # ascending, descending
var is_outbidding: bool

var most_recent_number_card_value: int
var selected_card_from_hand: Card
var saved_hovered_card: Card
var is_selected_card_valid: bool



@export var caravan_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees := 5
@export var y_sep := -10 # seperation between cards on the y axis in pixels, negative values mean the cards will cram together, positive values mean space in between
@export var x_min := 0 # offset on the x-axis compared to the caravan's position
@export var x_max := -15 # maximum amount of x offset that can be applied to cards based on the hand card

const CARD_SCENE_PATH = "res://Scenes/card.tscn" #temp


func _ready() -> void:
	caravan_value = 0

	_update_caravan_properties()
	pass # Replace with function body.
	
func reset_caravan():
	var total_cards := $tract.get_child_count()
	var removal_array: Array[Card]
	if total_cards != 0:
		var card: Card
		for i in total_cards: # iterate through all of the cards in the tract
			card = $tract.get_child(i)
			removal_array.append(card)

		for k in removal_array.size():
			$tract.remove_child(removal_array[k])
			card.reparent(get_tree().root)
			card.queue_free()
	
	caravan_value = 0
	is_sold = false
	caravan_suit = ""
	caravan_direction = ""
	is_outbidding = false
	
	most_recent_number_card_value = 0
	saved_hovered_card = null
	is_selected_card_valid = false

	_update_cards()
	_update_caravan_properties()


# If joker is placed on a number card, all of the other cards of this value are removed from the table, 
# except for the card it was placed on. 
func remove_num_cards_of_specified_value(number_card: Card):
	var removal_array: Array[Card]
	var total_cards := $tract.get_child_count()
	for i in total_cards: # iterate through all of the cards in the tract
		var card: Card = $tract.get_child(i)
		# add cards that match the value of the number card to an array, except for the number card it was played on
		if card != null and card != number_card and card.card_type == "number card" and card.value == number_card.value:
			removal_array.append(card)
			var j = 1
			while(true): # if there are kings in front of the number card added, add those aswell
				var next_card: Card = $tract.get_child(i + j)
				if next_card != null and next_card.card_type == "king":
					removal_array.append(next_card)
					j += 1
				else:
					break
		else:
			continue
	
		# delete all cards in the array at the end of the end of the function
		for k in removal_array.size():
			$tract.remove_child(removal_array[k])
			card.reparent(get_tree().root)
			card.queue_free()
			
		if $tract.get_child_count() == 0:
			reset_caravan()
		_update_cards()
		_update_caravan_properties()
	
	
# If joker is placed on an Ace, it removes all number cards of the Ace's suit, excluding the ace it was played on
func remove_num_cards_of_specified_suit(ace: Card):
	var removal_array: Array[Card]
	var total_cards := $tract.get_child_count()
	for i in total_cards: # iterate through all of the cards in the tract
		var card: Card = $tract.get_child(i)
		# add number cards that match the suit of the ace to an array, except for the ace it was played on
		if card != null and card != ace and card.card_type == "number card" and card.suit == ace.suit:
			removal_array.append(card)
			var j = 1
			while(true): # if there are kings in front of the number card added, add those aswell
				var next_card: Card = $tract.get_child(i + j)
				if next_card != null and next_card.card_type == "king":
					removal_array.append(next_card)
					j += 1
				else:
					break
		else:
			continue
	
		# delete all cards in the array at the end of the end of the function
		for k in removal_array.size():
			$tract.remove_child(removal_array[k])
			card.reparent(get_tree().root)
			card.queue_free()
		
		if $tract.get_child_count() == 0:
			reset_caravan()
		_update_cards()
		_update_caravan_properties()


func count_number_cards() -> int:
	var total_cards := $tract.get_child_count()
	var number_card_sum := 0
	for i in total_cards:
		var card: Card = $tract.get_child(i)
		if card.card_type == "number card":
			number_card_sum += 1
	return number_card_sum


func add_card_to_caravan(new_card: Card):
	new_card.visible = true
	if $tract.get_child_count() == 0 and caravan_suit == "":
		caravan_suit = new_card.suit
	if count_number_cards() == 1 and caravan_direction == "" and new_card.card_type == "number card": # set direction of caravan
		if new_card.value > most_recent_number_card_value:
			caravan_direction = "ascending"
		else:
			caravan_direction = "descending"

	$tract.add_child(new_card)
	if saved_hovered_card != null:
		var new_card_index: int = saved_hovered_card.get_index() + 1
		if new_card.card_type == "king":
			while(true):
				var card: Card = $tract.get_child(new_card_index)
				if card == null:
					break
				elif card.card_type != "king": # if the next card is not a king break
					break
				else: # if the next card is a king increment to the next index
					new_card_index += 1

		$tract.move_child(new_card, new_card_index)
		saved_hovered_card = null
	new_card.validate_face_card.connect(_on_validate_face_card) #connect card signal
	new_card.remove_face_card_projection.connect(_remove_projection)
	new_card.is_in_hand = false

	if new_card.card_type == "number card":
		most_recent_number_card_value = new_card.value

	if new_card.card_type == "queen":
		caravan_suit = new_card.suit
		if caravan_direction == "ascending":
			caravan_direction = "descending"
		else:
			caravan_direction = "ascending"

	if new_card.card_type == "king":
		var prev_index = new_card.get_index() - 1
		var sum := 0
		while(true):
			var card: Card = $tract.get_child(prev_index)
			if card.card_type == "king" or card.card_type == "number card":
				sum += card.value
				if card.card_type == "number card":
					break
				prev_index -= 1 # decrement to previous index if king
			else:
				break
		new_card.value = sum
			
	if new_card.card_type == "jack":
		var next_index = new_card.get_index() + 1
		var removal_array: Array[Card]
		removal_array.append($tract.get_child(new_card.get_index() - 1)) # add card behind jack to removal array
		while(true):
			var card: Card = $tract.get_child(next_index)
			if card == null:
				break
			elif card.card_type == "king":
				removal_array.append(card) # add king to removal array
				next_index += 1
			else:
				break

		removal_array.append(new_card)
		for i in removal_array.size():
			var card: Card = removal_array[i]
			$tract.remove_child(card)
			card.reparent(get_tree().root)
			card.queue_free()
			
	if new_card.card_type == "joker":
		var card_before_joker: Card = $tract.get_child(new_card.get_index() - 1)
		get_parent().joker_played(card_before_joker)
		
	if $tract.get_child_count() == 0:
		reset_caravan()
	_update_cards()
	_update_caravan_properties()


func _update_cards():
	var cards := $tract.get_child_count()
	if cards == 0:
		return
	var all_cards_size := Card.SIZE.y * cards + y_sep * (cards-1)
	var final_y_sep := y_sep

	if all_cards_size > $tract.size.y:
		final_y_sep = ($tract.size.y - Card.SIZE.y * cards) / (cards -1)
		all_cards_size = $tract.size.y

	var offset = ($tract.size.y - all_cards_size) / 2

	for i in cards:
		var card := $tract.get_child(i)
		#print("Card type: %s" %[card.card_type])
		var x_multiplier := caravan_curve.sample(1.0/ (cards-1) * i)
		var rot_multiplier := rotation_curve.sample(1.0 / (cards-1) *i)

		if cards == 1:
			x_multiplier = 0.0
			rot_multiplier = 0.0

		var final_x: float = x_min + x_max * x_multiplier
		var final_y: float = offset + Card.SIZE.y * i + final_y_sep * i

		card.position = Vector2(final_x,final_y)
		card.rotation_degrees = max_rotation_degrees * rot_multiplier


func _calculate_caravan_value():
	var cards := $tract.get_child_count()
	var value_sum: int = 0
	for i in cards:
		var card: Card = $tract.get_child(i)
		value_sum += card.value

	caravan_value = value_sum


func _update_caravan_properties():
	_calculate_caravan_value()
	if caravan_value > 20 and caravan_value < 27:
		$value_panel/value_text_label.text = "[color=black]%d" %[caravan_value]
		is_sold = true
	else:
		$value_panel/value_text_label.text = "[color=red]%d" %[caravan_value]
		is_sold = false
	
	match caravan_suit:
		"clubs": 
			$suit_panel/suit_text_label.text = "[color=black]♣"
		"diamonds":
			$suit_panel/suit_text_label.text = "[color=red]♦"
		"hearts":
			$suit_panel/suit_text_label.text = "[color=red]♥︎"
		"spades":
			$suit_panel/suit_text_label.text = "[color=black]♠︎"
		_: # if none of the patterns match
			$suit_panel/suit_text_label.text = ""

	match caravan_direction:
		"ascending":
			$direction_panel/direction_text_label.text = "↑"
		"descending":
			$direction_panel/direction_text_label.text = "↓"
		_: # if none of the patterns match
			$direction_panel/direction_text_label.text = ""
	
	if is_outbidding != null:
		$outbid_panel/outbid_text_label.visible = is_outbidding


# this nesting is making me sick
# go through this later and condense if else statements into elif statements where possible
# will need to double check FNV again to be sure but the logic for placing cards of the same suit is so strange
func check_placement_validity() -> bool:
	# makes it so the player cannot place number cards on CPU tracts
	if selected_card_from_hand.card_type == "number card" and owned_by == "cpu":
		return false
	if $tract.get_child_count() == 0: # when there are no cards in the caravan
		if selected_card_from_hand.card_type != "number card": # cannot place face cards when no number cards are in caravan
			return false
		else:
			return true
	else: # when there are already cards in the caravan
		if get_parent().is_setup_phase_over == false: # if setup phase is not over no more than 1 number card can be placed in a caravan
			return false

		if selected_card_from_hand.card_type == "number card":
			if caravan_direction == "": # aka there is only one card in the tract
				if selected_card_from_hand.value == most_recent_number_card_value:
					return false
				else:
					return true
			else: # first check direction, then check suit
				if caravan_direction == "ascending":   # "descending"
					if selected_card_from_hand.value > most_recent_number_card_value and selected_card_from_hand.suit != caravan_suit: 
						return true
					elif caravan_suit == selected_card_from_hand.suit: # now check suit
						return _value_search() # ensure that there is not already a card with the same value
					else:
						return false
				else: # if caravan direction is descending
					if selected_card_from_hand.value < most_recent_number_card_value and selected_card_from_hand.suit != caravan_suit:
						return true
					else: # now check suit
						if caravan_suit == selected_card_from_hand.suit:
							return _value_search() # ensure that there is not already a card with the same value
						else:
							return false
		elif selected_card_from_hand.card_type == "queen":
			if caravan_direction != "":
				return true
			else:
				return false
		else: # jacks, kings, jokers all require at least one number card in the caravan to play
			return true


# this function searches through the caravan to see if there is a number card of the same value
# if there are no cards in the caravan with the same value it returns true
# if there is a card with the same value it returns false
func _value_search() -> bool:
	var cards := $tract.get_child_count()
	for i in cards:
		var card: Card = $tract.get_child(i)
		if card.card_type != "number card": # skip face cards
			continue
		else:
			if selected_card_from_hand.value == card.value:
				return false
	
	return true





func project_placement():
	if check_placement_validity() == false:
		#print("Cannot place card here")
		is_selected_card_valid = false
		return
	else:
		print("Valid card placement")
		#add_card_to_caravan(selected_card_from_hand)
		if selected_card_from_hand.card_type == "number card" or "queen":
			$tract.add_child(selected_card_from_hand)
			_update_cards()
			is_selected_card_valid = true



func _on_validate_face_card(hovered_card: Card):
	if get_parent().is_setup_phase_over == false: # if setup phase is not over no more than 1 number card can be placed in a caravan
			return false
	var parent_node = get_parent()
	var refrence_card: Card = parent_node.on_request_selected_card()
	if refrence_card == null:
		is_selected_card_valid = false
		return
	elif refrence_card.card_type == "number card" or refrence_card.card_type == "queen":
		return # if number card or queen return
	else:
		_copy_refrence_card(refrence_card)

		if check_placement_validity_face_cards(hovered_card) == false:
			print("Cannot place card here")
			is_selected_card_valid = false
			return
		else:
			saved_hovered_card = hovered_card
			$tract.add_child(selected_card_from_hand)
			#move_child(selected_card_from_hand, hovered_card.get_index())
			selected_card_from_hand.position = hovered_card.position
			selected_card_from_hand.position.x =+ 15
			is_selected_card_valid = true
			

# This checks the placement validity of face cards excluding the queen
func check_placement_validity_face_cards(hovered_card: Card) -> bool:
	match selected_card_from_hand.card_type:
		"king":
			if hovered_card.card_type == "number card" or hovered_card.card_type == "king":
				return true
			else:
				return false
		"jack":
			if hovered_card.card_type == "number card" or hovered_card.card_type == "king":
				return true
			else:
				return false
		"joker":
			if hovered_card.card_type != "number card":
				return false
			else: 
				return true
		_: 
			return false


# This function triggers the placement projection for number cards and queens
func _on_back_panel_mouse_entered() -> void:
	var parent_node = get_parent()
	var refrence_card: Card = parent_node.on_request_selected_card()
	if refrence_card == null:
		is_selected_card_valid = false
		return
	elif refrence_card.card_type != "number card" and refrence_card.card_type != "queen":
		# All face cards except for queens return
		return
	else:
		_copy_refrence_card(refrence_card)
		project_placement()


# this functions sets the selected_card_from_hand global variable
func _copy_refrence_card(refrence_card: Card):
	var card_scene = preload(CARD_SCENE_PATH)
	if selected_card_from_hand != null:
		selected_card_from_hand.reparent(get_tree().root)
		selected_card_from_hand.queue_free()
		selected_card_from_hand = null
		
	selected_card_from_hand = card_scene.instantiate()
	selected_card_from_hand.card_name = refrence_card.card_name
	selected_card_from_hand.value = refrence_card.value
	selected_card_from_hand.suit = refrence_card.suit
	selected_card_from_hand.card_type = refrence_card.card_type
	selected_card_from_hand.is_in_hand = false
	selected_card_from_hand.is_projection = true
	var card_image_path = "res://Assets/%s.png" %[selected_card_from_hand.card_name]
	selected_card_from_hand.get_node("CardIMGfront").texture = load(card_image_path)
	selected_card_from_hand.toggle_highlight()
	selected_card_from_hand.get_node("Area2D").input_pickable = false
	


func _on_back_panel_mouse_exited() -> void:
	_remove_projection()

# If your selected card is valid ask the game script to move the card from
# your hand to this caravan
func _on_back_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if is_selected_card_valid != true:
				var parent = get_parent()
				if parent.on_request_selected_card() == null and owned_by == "player" and $tract.get_child_count() > 0:
					parent.caravan_clicked_with_no_card(self.name)
				return
			
			var parent_node = get_parent()
			_remove_projection()
			# ask parent to place the selected card in the hand
			parent_node.add_card_to_caravan(self.name)
	

# This function removes the projected card from the caravan
func _remove_projection():
	#is_validation_in_use = false
	
	if selected_card_from_hand == null:
		return
	is_selected_card_valid = false
	selected_card_from_hand.reparent(get_tree().root)
	selected_card_from_hand.queue_free()
	selected_card_from_hand = null
	
	_update_cards()


func toggle_highlight_caravan():
	if $selection_outline.visible == true:
		$selection_outline.visible = false
	else:
		$selection_outline.visible = true
	pass
