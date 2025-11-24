extends Node2D

@onready var hand: Hand = $Hand
@onready var deck: Deck = $Deck
const CARAVAN_SCENE_PATH="res://Scenes/caravan.tscn"

var is_setup_phase_over: bool 

func _ready() -> void:
	get_viewport().physics_object_picking_first_only = true
	get_viewport().physics_object_picking_sort = true
	is_setup_phase_over = false
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
	print("this will eventually discard a tract")


func _on_debug_reset_button_pressed() -> void:
	get_tree().reload_current_scene()

func disable_mouse_inputs_for_caravans():
	for i in 3:
		var caravan_name: String = "player_caravan_%d" %[i]
		var node: Caravan = get_node(caravan_name)
		node.get_node("back_panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	for k in 3:
		var caravan_name: String = "cpu_caravan_%d" %[k]
		var node: Caravan = get_node(caravan_name)
		node.get_node("back_panel").mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	
func enable_mouse_inputs_for_caravans():
	for i in 3:
		var caravan_name: String = "player_caravan_%d" %[i]
		var node: Caravan = get_node(caravan_name)
		node.get_node("back_panel").mouse_filter = Control.MOUSE_FILTER_PASS
		
	for k in 3:
		var caravan_name: String = "cpu_caravan_%d" %[k]
		var node: Caravan = get_node(caravan_name)
		node.get_node("back_panel").mouse_filter = Control.MOUSE_FILTER_PASS
