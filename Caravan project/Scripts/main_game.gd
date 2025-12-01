extends Node2D

@onready var hand: Hand = $Hand
@onready var deck: Deck = $Deck
@onready var opponent_deck: opponent_deck = $Opponent_deck
@onready var opponent_hand: opponent_hand = $Opponent_hand

const CARAVAN_SCENE_PATH="res://Scenes/caravan.tscn"

var is_setup_phase_over: bool 
var caravan_selected_for_reset: String
var current_turn: String


func _ready() -> void:
	get_viewport().physics_object_picking_first_only = true
	get_viewport().physics_object_picking_sort = true
	is_setup_phase_over = false
	deck.load_deck()
	opponent_deck.cpu_deck.shuffle()
	for i in 8: # draw 8 cards from deck on startup
		deck.draw_card()
		opponent_deck.draw_cpu_card()

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

	current_turn = "player"
	update_turn_panel()


func update_turn_panel():
	var turn_label: String
	if current_turn == "player":
		turn_label = "Current turn: [color=#8cc7ef]Player" 
	else:
		turn_label = "Current turn: [color=#f5b5c5]CPU" 
	$turn_display_panel/current_turn_text_label.text = turn_label


func advance_turn():
	win_loss_conditions() # check the win conditions
	if is_setup_phase_over == false:
		check_setup_round() # check if the setup phase is over
	
	if current_turn == "player": # if it's currently the players turn change it to the CPU
		current_turn = "cpu"
		update_turn_panel()
		cpu_decide_action()
	else:
		current_turn = "player"
		update_turn_panel()


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
	advance_turn()


func _on_discard_card_button_pressed() -> void:
	hand._discard()
	if is_setup_phase_over:
		advance_turn()


func _on_discard_tract_button_pressed() -> void:
	if caravan_selected_for_reset != "":
		var node: Caravan = get_node(caravan_selected_for_reset)
		node.reset_caravan()
		remove_caravan_selection()
		toggle_discard_tract_button()
		advance_turn()
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


func win_loss_conditions():
	var player_caravan: Caravan
	var cpu_caravan: Caravan
	var player_caravan_name: String
	var cpu_caravan_name: String
	var who_won: String
	var reason_for_win: String
	var number_of_ties := 0
	var number_of_cpu_outbids := 0
	var number_of_player_outbids := 0
	var number_of_player_caravans_sold := 0
	var number_of_cpu_caravans_sold := 0

	for i in 3:
		player_caravan_name = "player_caravan_%d" %[i]
		cpu_caravan_name = "cpu_caravan_%d" %[i]
		player_caravan = get_node(player_caravan_name)
		cpu_caravan = get_node(cpu_caravan_name)

		# confirm that both caravans are in the 21-26 range of value
		if player_caravan.caravan_value > 20 and player_caravan.caravan_value < 27:
			if cpu_caravan.caravan_value > 20 and cpu_caravan.caravan_value < 27:
				# compare the values of both caravans and assign value of is_outbidding
				if player_caravan.caravan_value == cpu_caravan.caravan_value:
					player_caravan.is_outbidding = false
					cpu_caravan.is_outbidding = false
					number_of_ties += 1
				if player_caravan.caravan_value > cpu_caravan.caravan_value:
					player_caravan.is_outbidding = true
					cpu_caravan.is_outbidding = false
				if player_caravan.caravan_value < cpu_caravan.caravan_value:
					player_caravan.is_outbidding = false
					cpu_caravan.is_outbidding = true

				player_caravan._update_caravan_properties()
				cpu_caravan._update_caravan_properties()

		if player_caravan.is_sold == true:
			number_of_player_caravans_sold += 1

		if cpu_caravan.is_sold == true:
			number_of_cpu_caravans_sold += 1

	# check to see if the game should end
	if number_of_ties == 0: # if there are no ties
		if number_of_cpu_caravans_sold == 3: # check to see if the player of CPU has 3 caravans sold
			who_won = "CPU"
			reason_for_win = "The CPU sold all 3 of their caravans with no ties!"
			end_game(who_won,reason_for_win)
		if number_of_player_caravans_sold == 3:
			who_won = "Player"
			reason_for_win = "You sold all 3 of your Caravans with no ties!"
			end_game(who_won,reason_for_win)

	if number_of_player_outbids >= 2:
		who_won = "Player"
		reason_for_win = "You outbid %d of your opponents Caravans!" %[number_of_player_outbids]
		end_game(who_won,reason_for_win)
	if number_of_cpu_outbids >= 2:
		who_won = "CPU"
		reason_for_win = "The CPU outbid %d of your Caravans!" %[number_of_cpu_outbids]
		end_game(who_won,reason_for_win)

	# this is checking the player deck
	if deck.deck.size() == 0:
		who_won = "CPU"
		reason_for_win = "You ran out of cards in your deck!"
		end_game(who_won,reason_for_win)

	if opponent_deck.cpu_deck.size() == 0:
		who_won = "Player"
		reason_for_win = "The CPU ran out of cards in their deck!"
		end_game(who_won,reason_for_win)


func end_game(victor: String, reason: String):
	$end_screen_panel/victor_text_label.text = "%s wins!" %[victor]
	$end_screen_panel/reason_text_label.text = reason
	$end_screen_panel.visible = true


func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


# this function checks all of the caravans on the board to see if a card has been placed 
func check_setup_round():
	var pc0: Caravan = get_node("player_caravan_0")
	var pc1: Caravan = get_node("player_caravan_1")
	var pc2: Caravan = get_node("player_caravan_2")

	var cc0: Caravan = get_node("cpu_caravan_0")
	var cc1: Caravan = get_node("cpu_caravan_1")
	var cc2: Caravan = get_node("cpu_caravan_2")

	if pc0.first_card_played and pc1.first_card_played and pc2.first_card_played:
		if cc0.first_card_played and cc1.first_card_played and cc2.first_card_played:
			is_setup_phase_over = true


func cpu_decide_action():
	# Wait a random amount of time between 1 - 3.5 seconds
	var random_time = RandomNumberGenerator.new().randf_range(1.0, 3.5) 
	get_node("opponent_timer").wait_time = random_time
	get_node("opponent_timer").start()
	await get_node("opponent_timer").timeout

	if is_setup_phase_over == false: # if setup phase is NOT over
		cpu_setup_phase_action() 
	elif is_cpu_overburdened(): # remove any overburdened Caravans
		print("CPU decided to reset Caravan")
	elif cpu_normal_action(): # try to place a valid card in any of the caravans
		print("CPU decided to play a card")
	else: 
		opponent_hand.discard_random_card()

	advance_turn()


func cpu_setup_phase_action():
	opponent_hand.select_lowest_card() # select the lowest value card in the CPU's hand
	var cpu_caravan_name: String
	for i in 3: # place that card in an unoccupied caravan
		cpu_caravan_name = "cpu_caravan_%d" %[i]
		var cpu_caravan: Caravan = get_node(cpu_caravan_name)
		if cpu_caravan.first_card_played == false:
			cpu_play_card(cpu_caravan) # send that card into the caravan
			break

# removes the first overburdened caravan found
# returns true when overburdened caravan is found
# returns false if no overburdened caravan is found
func is_cpu_overburdened() -> bool:
	var cpu_caravan_name: String
	for i in 3:
		cpu_caravan_name = "cpu_caravan_%d" %[i]
		var cpu_caravan: Caravan = get_node(cpu_caravan_name)
		if cpu_caravan.caravan_value > 26: # if the tract is overburdened 
			cpu_caravan.reset_caravan() # reset that tract and break out of the loop
			return true
		
	return false 


func cpu_normal_action():
	var cpu_caravan_name: String
	var cpu_caravan: Caravan
	var value_sum: int
	for i in 3:
		cpu_caravan_name = "cpu_caravan_%d" %[i]
		cpu_caravan = get_node(cpu_caravan_name)
		var most_recent_card = cpu_caravan.most_recent_number_card_value
		var value_array: Array[int] = cpu_caravan.return_array_of_values()
		value_sum = cpu_caravan.caravan_value
		# need to also check to make sure that the card about to be selected is not already an existing card in the caravan
		if opponent_hand.select_card_most_close_to_value(most_recent_card, value_sum, value_array):
			# if a card that matches the requirements is found 
			cpu_play_card(cpu_caravan)
			return true
	
	for j in 3: # if the above fails try this now
		cpu_caravan_name = "cpu_caravan_%d" %[j]
		cpu_caravan = get_node(cpu_caravan_name)
		var caravan_suit := cpu_caravan.caravan_suit
		value_sum = cpu_caravan.caravan_value
		var value_array: Array[int] = cpu_caravan.return_array_of_values()
		if opponent_hand.select_card_with_same_suit(caravan_suit, value_sum, value_array):
			# if a card that matches the requirements is found 
			cpu_play_card(cpu_caravan)
			return true

	return false # if a card cant be placed in any of the caravans return false


func cpu_play_card(cpu_caravan: Caravan):
	var card: Card = opponent_hand.play_card() 
	card.get_node("CardIMGback").visible = false
	card.get_node("CardIMGfront").visible = true
	cpu_caravan.add_card_to_caravan(card)
	if opponent_deck.cpu_deck.size() != 0 and is_setup_phase_over:
		opponent_deck.draw_cpu_card()