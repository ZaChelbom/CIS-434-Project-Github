class_name Caravan
extends Node2D

var owned_by: String

var caravan_value: int# the sum value of the caravan
var is_sold: bool
var caravan_suit: String # clubs, diamonds, hearts, spades
var caravan_direction: String # ascending, descending
var is_outbidding: bool

@export var caravan_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation_degrees := 5
@export var y_sep := -10 # seperation between cards on the y axis in pixels, negative values mean the cards will cram together, positive values mean space in between
@export var x_min := 0 # offset on the x-axis compared to the caravan's position
@export var x_max := -15 # maximum amount of x offset that can be applied to cards based on the hand card

const CARD_SCENE_PATH="res://Scenes/card.tscn" #temp





func _ready() -> void:
	caravan_value = 0
	_update_caravan_properties()
	pass # Replace with function body.


func add_card_to_caravan():
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$tract.add_child(new_card)
	_update_cards()

func add_card_to_cpu_caravan(new_card: Card, caravan_index: int):
	var caravan := get_child(caravan_index)
	var card_count := caravan.get_child_count()
	
	# set suit if caravan is empty 
	if card_count == 0 and caravan_suit == "":
		caravan_suit = new_card.suit
		caravan.add_child(new_card)
		
	# set direction if this is the second card
	if card_count == 1 and caravan_direction == "":
		if new_card.value > most_recent_number_card.value:
			caravan_direction = "ascending"
		else:
			caravan_direction = "descending"
			
	# move card to correct position
	var new_card_index := saved_hovered_card.get_index() + 1
	caravan.move_child(new_card, new_card_index)
	# connect signals
	new_card.validate_face_card.connect(_on_validate_face_card)
	new_card.remove_face_card_projection.connect(_remove_projection)
	new_card.is_in_cpu_hand = false
	
	# track most recent number card
	if new_card.card_type == "number card":
		most_recent_number_card = new_card
	
	_update_cards()
	_update_caravan_properties()

func add_card_to_cpu_caravan(new_card: Card, caravan_index: int):
	var caravan := get_child(caravan_index)
	var card_count := caravan.get_child_count()
	
	# set suit if caravan is empty 
	if card_count == 0 and caravan_suit == "":
		caravan_suit = new_card.suit
		caravan.add_child(new_card)
		
	# set direction if this is the second card
	if card_count == 1 and caravan_direction == "":
		if new_card.value > most_recent_number_card.value:
			caravan_direction = "ascending"
		else:
			caravan_direction = "descending"
			
	# move card to correct position
	var new_card_index := saved_hovered_card.get_index() + 1
	caravan.move_child(new_card, new_card_index)
	# connect signals
	new_card.validate_face_card.connect(_on_validate_face_card)
	new_card.remove_face_card_projection.connect(_remove_projection)
	new_card.is_in_cpu_hand = false
	
	# track most recent number card
	if new_card.card_type == "number card":
		most_recent_number_card = new_card
	
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





func _update_caravan_properties():
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
