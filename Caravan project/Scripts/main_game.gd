extends Node2D

@onready var hand: Hand = $Hand
@onready var deck: Deck = $Deck
const CARAVAN_SCENE_PATH="res://Scenes/caravan.tscn"

var is_setup_phase_over: bool 
var caravan_selected_for_reset: String

func _ready() -> void:
	get_viewport().physics_object_picking_first_only = true
	get_viewport().physics_object_picking_sort = true
	is_setup_phase_over = true
	deck.load_deck()
	for i in 8: # draw 8 cards from deck on startup
		deck.draw_card()

	for i in 3: # create 3 player caravans
		var caravan_scene = preload(CARAVAN_SCENE_PATH)
		var new_caravan = caravan_scene.instantiate()
		new_caravan.owned_by = "player"
		new_caravan.name = "player_caravan_%d" %[i]
		add_child(new_caravan)
		new_caravan.position = Vector2(i*240,360)

	for i in 3: # create 3 opponent caravans
		var caravan_scene = preload(CARAVAN_SCENE_PATH)
		var new_caravan = caravan_scene.instantiate()
		new_caravan.owned_by = "cpu"
		new_caravan.name = "cpu_caravan_%d" %[i]
		add_child(new_caravan)
		new_caravan.position = Vector2(i*240,-8)


# this function is called when projecting a copy of selected card to the caravan
func on_request_selected_card():
	if hand.selected_card == null:
		print("There is no selected card to send")
		return null
	else:
		return hand.selected_card


func _on_draw_card_button_pressed() -> void:
	pass


# called when you click on a caravan with a card selected from hand
func add_card_to_caravan(node_name: String):
	var card: Card = hand.play_card()
	card.toggle_highlight()
	var caravan_node = get_node(node_name)
	caravan_node.add_card_to_caravan(card)
	if is_setup_phase_over:
		deck.draw_card()


func _on_discard_card_button_pressed() -> void:
	hand._discard()


func _on_discard_tract_button_pressed() -> void:
	if caravan_selected_for_reset != "":
		var node: Caravan = get_node(caravan_selected_for_reset)
		node.reset_caravan()
		remove_caravan_selection()
		toggle_discard_tract_button()
	else:
		print("This should not happen")


func _on_debug_reset_button_pressed() -> void:
	get_tree().reload_current_scene()


func joker_played(card_before_joker: Card):
	for i in 2:
		for j in 3:
			var caravan_name: String
			if i == 0:
				caravan_name = "player_caravan_%d" %[j]
			else:
				caravan_name = "cpu_caravan_%d" %[j]
			
			var node: Caravan = get_node(caravan_name)
			if card_before_joker.value == 1: # if the joker was played on an ace 
				#remove all num cards of suit of ace, except for the card it was placed on
				node.remove_num_cards_of_specified_suit(card_before_joker)
			else:
				#remove value of number card 2-10, except for the card it was placed on
				node.remove_num_cards_of_specified_value(card_before_joker)
		
# this function is called when a caravan is clicked on without a card selected
func caravan_clicked_with_no_card(caravan: String):
	var node: Caravan
	if caravan_selected_for_reset == "": # if a caravan is not currently selected
		caravan_selected_for_reset = caravan
		node = get_node(caravan_selected_for_reset)
		node.toggle_highlight_caravan()
	elif caravan_selected_for_reset == caravan: # if you are clicking on the same caravan that is already selected
		node = get_node(caravan_selected_for_reset)
		node.toggle_highlight_caravan()
		caravan_selected_for_reset = ""
	else: # if there is currently a caravan selected
		node = get_node(caravan_selected_for_reset) # get the node of the currently highlighted caravan
		node.toggle_highlight_caravan() # toggle it's highlight
		caravan_selected_for_reset = caravan # set the new highlighted caravan 
		node = get_node(caravan_selected_for_reset)
		node.toggle_highlight_caravan()

	toggle_discard_tract_button() 


func remove_caravan_selection():
	if caravan_selected_for_reset != "": # if caravan selected for highlight exists, turn it off
		var node: Caravan = get_node(caravan_selected_for_reset)
		node.toggle_highlight_caravan()
		caravan_selected_for_reset = ""
	else:
		return

# this function enables/disables the discard tract button based on the existance of the caravan_selected_for_reset variable
func toggle_discard_tract_button():
	if caravan_selected_for_reset != "": # if a caravan selected for reset exists
		$discard_tract_button.disabled = false
	else: # if it does not exist
		$discard_tract_button.disabled = true
