extends TextureButton

signal updateDeck(is_deck_button,card_type,card_suit)

const DECK_BUILDER_PATH = "res://Scenes/deck_builder.gd"

var card_type: String
var card_suit: int
var number_of_cards: int
var is_deck_button: bool

@onready var number_label = $number_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().get_node("Deck_builder").updateCard.connect(_on_updateCard) #connect the signal
	if is_deck_button and number_of_cards == 0:
		number_label.text = "x%d" %[number_of_cards]
		$".".modulate = Color(1,1,1,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_updateCard(check_button,check_card_type,check_card_suit):
	if is_deck_button != check_button && check_card_type == card_type && card_suit == check_card_suit:
		#print("Update card signal received")
		#print("New card number: %d" %new_card_number)
		number_of_cards += 1
		number_label.text = "x%d" %[number_of_cards]
		if is_deck_button:
			$".".modulate = Color(1,1,1,1)
		else:
			pass
			#$".".modulate = Color(1,1,1,1)
	else:
		pass

# when the button is pressed, decrement the card counter on the button and
# increment the counter on the opposing card
func _on_pressed() -> void:
	#print(number_of_cards)
	if number_of_cards > 0: #decrement label 
		number_of_cards -= 1
		number_label.text = "x%d" %[number_of_cards]
		updateDeck.emit(is_deck_button,card_type,card_suit) # emit signal
		#print(card_type)
		if number_of_cards == 0:
			if is_deck_button: 
				$".".modulate = Color(1,1,1,0)
			else:
				pass
				#$".".modulate = Color(1,1,1,50)
	else:
		pass
	
