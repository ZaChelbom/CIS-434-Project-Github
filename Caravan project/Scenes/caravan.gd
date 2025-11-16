class_name Caravan
extends Node2D

var owned_by: String

var caravan_value: int# the sum value of the caravan
var is_sold: bool
var caravan_suit: String # clubs, diamonds, hearts, spades
var caravan_direction: String # ascending, descending
var is_outbidding: bool

var most_recent_number_card: Card
var selected_card_from_hand: Card
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
	most_recent_number_card = null

	_update_caravan_properties()
	pass # Replace with function body.


func add_card_to_caravan(new_card: Card):
	new_card.visible = true
	if $tract.get_child_count() == 0 and caravan_suit == "":
		caravan_suit = new_card.suit
	if $tract.get_child_count() == 1 and caravan_direction == "": # set direction of caravan
		if new_card.value > most_recent_number_card.value:
			caravan_direction = "ascending"
		else:
			caravan_direction = "descending"

	$tract.add_child(new_card)
	if new_card.card_type == "number card":
		most_recent_number_card = new_card

	if new_card.card_type == "queen":
		caravan_suit = new_card.suit
		if caravan_direction == "ascending":
			caravan_direction = "descending"
		else:
			caravan_direction = "ascending"

	_update_cards()
	_update_caravan_properties()




func _update_cards():
	var cards := $tract.get_child_count()
	var all_cards_size := Card.SIZE.y * cards + y_sep * (cards-1)
	var final_y_sep := y_sep

	if all_cards_size > $tract.size.y:
		final_y_sep = ($tract.size.y - Card.SIZE.y * cards) / (cards -1)
		all_cards_size = $tract.size.y

	var offset = ($tract.size.y - all_cards_size) / 2

	for i in cards:
		var card := $tract.get_child(i)
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
				if selected_card_from_hand.value == most_recent_number_card.value:
					return false
				else:
					return true
			else: # first check direction, then check suit
				if caravan_direction == "ascending":   # "descending"
					if selected_card_from_hand.value > most_recent_number_card.value and selected_card_from_hand.suit != caravan_suit: 
						return true
					elif caravan_suit == selected_card_from_hand.suit: # now check suit
						return _value_search() # ensure that there is not already a card with the same value
					else:
						return false
				else: # if caravan direction is descending
					if selected_card_from_hand.value < most_recent_number_card.value and selected_card_from_hand.suit != caravan_suit:
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
		print("Cannot place card here")
		is_selected_card_valid = false
		return
	else:
		print("Valid card placement")
		#add_card_to_caravan(selected_card_from_hand)
		$tract.add_child(selected_card_from_hand)
		_update_cards()
		is_selected_card_valid = true
	


func _on_back_panel_mouse_entered() -> void:
	var parent_node = get_parent()
	var refrence_card: Card = parent_node.on_request_selected_card()
	if refrence_card == null:
		is_selected_card_valid = false
		return
	else:
		var card_scene = preload(CARD_SCENE_PATH)
		selected_card_from_hand = card_scene.instantiate()
		selected_card_from_hand.card_name = refrence_card.card_name
		selected_card_from_hand.value = refrence_card.value
		selected_card_from_hand.suit = refrence_card.suit
		selected_card_from_hand.card_type = refrence_card.card_type
		selected_card_from_hand.is_in_hand = false
		var card_image_path = "res://Assets/%s.png" %[selected_card_from_hand.card_name]
		selected_card_from_hand.get_node("CardIMGfront").texture = load(card_image_path)
		selected_card_from_hand.toggle_highlight()
		project_placement()


func _on_back_panel_mouse_exited() -> void:
	_remove_projection()
	pass # Replace with function body.


func _on_back_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if is_selected_card_valid != true:
				return
			
			print("Caravan clicked!")
			var parent_node = get_parent()
			_remove_projection()
			# ask parent to place the selected card in the hand
			parent_node.add_card_to_caravan(self.name)
			
			pass
		

func _remove_projection():
	if selected_card_from_hand == null:
		return
	
	#selected_card_from_hand.reparent(get_tree().root)
	$tract.remove_child(selected_card_from_hand)
	selected_card_from_hand.queue_free()
	selected_card_from_hand = null
	is_selected_card_valid = false
	_update_cards()
