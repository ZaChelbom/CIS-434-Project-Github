class_name Deck
extends Node2D

const CARD_SCENE_PATH="res://Scenes/card.tscn"
var deck = []

var card_suit_array = [
	"clubs",
	"diamonds",
	"hearts",
	"spades"
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_deck():
	SaveLoadManager._load()
	var saved_deck_keys_array = SaveLoadManager.deck_to_save.keys()
	var card
	for i in 13:
		for j in 4:
			if SaveLoadManager.deck_to_save[saved_deck_keys_array[i]][j] == 0:
				continue
			
			for k in SaveLoadManager.deck_to_save[saved_deck_keys_array[i]][j]:
				card = str(saved_deck_keys_array[i]) + "_of_" + str(card_suit_array[j])
				deck.insert(0,card)
				
	for l in SaveLoadManager.deck_to_save["joker"][0]: #load the jokers
		card = "joker"
		deck.insert(0,card)

	deck.shuffle()
	_update_deck()


func _update_deck():
	if deck.size() == 0:
		$DeckImage.visible = false
	$DeckLabel.text = "Deck: %d" % [deck.size()]


func draw_card():
	if deck.size() == 0:
		print("Empty deck")
		return
	
	var card_drawn_name = deck[0]
	deck.erase(card_drawn_name)
	var card_image_path = "res://Assets/%s.png" %[card_drawn_name]
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.get_node("CardIMGfront").texture = load(card_image_path)
	new_card.card_type = card_drawn_name
	$"../Hand".add_card_to_hand(new_card)
	_update_deck()


# Called every frame. 'delta' is the elapsed time since the prev9ious frame.
func _process(delta: float) -> void:
	pass
