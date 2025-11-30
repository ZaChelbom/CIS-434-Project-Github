class_name opponent_deck
extends Node2D

const CARD_SCENE_PATH="res://Scenes/card.tscn"
# deafult cpu deck of 30 non face cards 
const CARD_DATABASE_PATH = "res://Scripts/card_database.gd"
var cpu_deck = ["10_of_hearts", "9_of_hearts", "8_of_hearts", "7_of_hearts",
"6_of_hearts", "5_of_hearts", "4_of_hearts", "3_of_hearts", "2_of_hearts", 
"10_of_diamonds", "9_of_diamonds", "8_of_diamonds", "7_of_diamonds", 
"6_of_diamonds", "4_of_diamonds", "2_of_diamonds", "9_of_spades", "7_of_spades", 
"6_of_spades", "5_of_spades", "4_of_spades", "3_of_spades", "10_of_clubs", 
"8_of_clubs","7_of_clubs", "6_of_clubs", "5_of_clubs", "4_of_clubs", "2_of_clubs"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# cpu_deck.shuffle()
	# _update_cpu_deck()

func _update_cpu_deck():
	if cpu_deck.size() == 0:
		$DeckImage.visible = false
	$DeckLabel.text = "Deck: %d" % [cpu_deck.size()]

func draw_cpu_card():
	if cpu_deck.size() == 0:
		print("Empty cpu deck")
		return
	
	var card_drawn_name = cpu_deck[0]
	cpu_deck.erase(card_drawn_name)
	var card_image_path = "res://Assets/%s.png" %[card_drawn_name]
	var card_scene = preload(CARD_SCENE_PATH)
	var card_database = preload(CARD_DATABASE_PATH) # this is dumb and bad I should have scrapped this
	var new_card = card_scene.instantiate()
	new_card.get_node("CardIMGfront").texture = load(card_image_path)
	new_card.get_node("CardIMGback").texture = load("res://Assets/cardChii.png")
	new_card.get_node("CardIMGback").visible = true
	new_card.get_node("CardIMGfront").visible = false

	new_card.value = card_database.CARDS[card_drawn_name][0]
	new_card.suit = card_database.CARDS[card_drawn_name][1]
	new_card.card_type = card_database.CARDS[card_drawn_name][2]
	new_card.card_name = card_drawn_name
	
	$"../Opponent_hand".add_card_to_hand(new_card)
	_update_cpu_deck()


# Called every frame. 'delta' is the elapsed time since the prev9ious frame.
func _process(delta: float) -> void:
	pass
