extends Node2D

signal updateCard(is_deck_button,card_type,card_suit)

const CARD_BUTTON_PATH = "res://Scenes/card_button.tscn"
const MAX_NUMBER_CARDS = 6

var card_database_reference
var card_button
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
	_create_cards()
	# disable the scrollbar of container 2
	scroll_container2.get_v_scroll_bar().mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _on_update_deck(is_deck_button,card_type,card_suit):
	print("Update deck signal recieved")
	if is_deck_button:
		deck[card_type][card_suit] -= 1
	else:
		deck[card_type][card_suit] += 1
	
	updateCard.emit(is_deck_button,card_type,card_suit)
	print("Number of %s in deck: %d" %[card_type, deck[card_type][card_suit]])
	
func _create_cards():
	card_button = preload(CARD_BUTTON_PATH)
	var new_button
	var card_image_path
	for k in 2: # 0-1 : 0 = available card button or 1 = deck card button
		for i in 13: # 0-12 : card type 
			for j in 4: # 0-3 : card suit 
				new_button = card_button.instantiate() # create new button
				card_image_path = str("res://Assets/" + deck_keys_array[i] + "_of_" + card_suit_array[j] + ".png")
				new_button.texture_normal = load(card_image_path)
				new_button.card_type = str(deck_keys_array[i])
				new_button.card_suit = j
				new_button.updateDeck.connect(_on_update_deck)
				if k == 0: # available cards
					new_button.is_deck_button = false
					new_button.number_of_cards = MAX_NUMBER_CARDS - deck[deck_keys_array[i]][j] 
					$ScrollContainer/VBoxContainer/GridContainer.add_child(new_button)
				else: # deck cards 
					new_button.is_deck_button = true
					new_button.number_of_cards = deck[deck_keys_array[i]][j]
					$ScrollContainer2/VBoxContainer/GridContainer.add_child(new_button)
	
	#add jokers at the end
		new_button = card_button.instantiate()
		card_image_path = str("res://Assets/red_joker.png")
		new_button.texture_normal = load(card_image_path)
		new_button.card_type = "red_joker"
		new_button.updateDeck.connect(_on_update_deck)
		
		if k == 0: #available cards - joker
			new_button.number_of_cards = MAX_NUMBER_CARDS - deck["joker"][0] 
			new_button.is_deck_button = false
			$ScrollContainer/VBoxContainer/GridContainer.add_child(new_button)
		else: #deck cards - joker
			new_button.number_of_cards = deck["joker"][0] 
			new_button.is_deck_button = true
			$ScrollContainer2/VBoxContainer/GridContainer.add_child(new_button)


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
