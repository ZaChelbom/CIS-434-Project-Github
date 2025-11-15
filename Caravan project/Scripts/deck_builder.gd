class_name DeckBuilder
extends Node2D

signal clickUpdateCard(is_deck_button,card_type,card_suit)
signal updateCard()

const CARD_BUTTON_PATH = "res://Scenes/card_button.tscn"
const MAX_NUMBER_CARDS = 6

var card_button
var card_counter: int = 0
#var saved_deck = # will go to user's %appdata% folder
var card_suit_array = [
	"clubs",
	"diamonds",
	"hearts",
	"spades"
]
var deck = {
	# number of: clubs, diamonds, hearts, spades
	"ace" : [0,0,0,0],
	"2" : [0,0,0,0],
	"3" : [0,0,0,0],
	"4" : [0,0,0,0],
	"5" : [0,0,0,0],
	"6" : [0,0,0,0],
	"7" : [0,0,0,0],
	"8" : [0,0,0,0],
	"9" : [0,0,0,0],
	"10" : [0,0,0,0],
	"jack" : [0,0,0,0],
	"queen" : [0,0,0,0],
	"king" : [0,0,0,0],
	# number of jokers
	"joker" : [0]
}
var deck_keys_array = deck.keys()

@onready var scroll_container1: ScrollContainer = $ScrollContainer
@onready var scroll_container2: ScrollContainer = $ScrollContainer2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if SaveLoadManager._load() == null:
		print("No save file found")
		SaveLoadManager.deck_to_save = deck
	else:
		print("Save file found")
		deck = SaveLoadManager.deck_to_save
		
	
	_create_cards()
	updateCard.emit()
	# disable the scrollbar of container 2
	scroll_container2.get_v_scroll_bar().mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_card_counter()
	

func _is_deck_valid():
	pass
	

func _on_update_deck(is_deck_button,card_type,card_suit):
	print("Update deck signal recieved")
	if is_deck_button:
		deck[card_type][card_suit] -= 1
		card_counter -= 1
	else:
		deck[card_type][card_suit] += 1
		card_counter += 1
	
	_update_card_counter()
	clickUpdateCard.emit(is_deck_button,card_type,card_suit)
	print("Number of %s in deck: %d" %[card_type, deck[card_type][card_suit]])


func _create_cards():
	for k in 2: # Determines button type: Goes from 0-1, 0 = available card button, 1 = deck card button
		for i in 14: # Determines Card type: Goes from 0-13, each number represents a card type (not including jokers)
			for j in 4: # Determines card suit: Goes from 0-3, each number represents a suit
				_set_card_parameters(k,deck_keys_array[i],j)


func _set_card_parameters(button_type, card_type, card_suit):
	if (card_type == "joker" and card_suit != 3): # logic to prevent the creation of more than 2 joker card buttons
		return
	
	card_button = preload(CARD_BUTTON_PATH)
	var card_image_path: String

	if (card_type == "joker"):
		card_image_path = str("res://Assets/" + card_type + ".png")
		card_suit = 0 # set card suit to 0 so the deck array can properly be accessed for jokers without more nesting
	else:
		card_image_path = str("res://Assets/" + card_type + "_of_" + card_suit_array[card_suit] + ".png")

	var new_button = card_button.instantiate() # create new button object

	new_button.texture_normal = load(card_image_path)
	new_button.updateDeck.connect(_on_update_deck) # connect update deck signal
	
	new_button.card_texture = card_image_path # card button variable to remember texture
	new_button.card_type = str(card_type)
	if (card_type != "joker"):
		new_button.card_suit = card_suit

	if (button_type == 0): # Available cards section button
		new_button.is_deck_button = false
		new_button.number_of_cards = MAX_NUMBER_CARDS - deck[card_type][card_suit] 
		$ScrollContainer/VBoxContainer/GridContainer.add_child(new_button) # add button as child to left side grid container
	else: # Deck cards section button
		new_button.is_deck_button = true
		if deck[card_type][card_suit] != 0:
			card_counter += deck[card_type][card_suit]
		new_button.number_of_cards = deck[card_type][card_suit]
		$ScrollContainer2/VBoxContainer/GridContainer.add_child(new_button) # add button as child to right side grid container


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton: #code to handle scrolling
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_container1.scroll_vertical -= 25
			scroll_container2.scroll_vertical -= 25
			#print("Mouse wheel up")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_container1.scroll_vertical += 25
			scroll_container2.scroll_vertical += 25
			#print("Mouse wheel down")


func _update_card_counter():
	if card_counter < 30:
		$CardCounterLabel.add_theme_color_override("font_color",Color(255,0,0))
		$MainMenuButton.disabled = true
	else:
		$CardCounterLabel.add_theme_color_override("font_color",Color(255,1,1))
		$MainMenuButton.disabled = false
		
	$CardCounterLabel.text = "Cards: %d" %card_counter
