class_name CPUDeck
extends Node2D

const CARD_SCENE_PATH="res://Scenes/card.tscn"
# deafult cpu deck of 30 non face cards 
var cpu_deck = ["10_of_hearts", "9_of_hearts", "8_of_hearts", "7_of_hearts",
"6_of_hearts", "5_of_hearts", "4_of_hearts", "3_of_hearts", "2_of_hearts", 
"10_of_diamonds", "9_of_diamonds", "8_of_diamonds", "7_of_diamonds", 
"6_of_diamonds", "4_of_diamonds", "2_of_diamonds", "9_of_spades", "7_of_spades", 
"6_of_spades", "5_of_spades", "4_of_spades", "3_of_spades", "10_of_clubs", 
"8_of_clubs","7_of_clubs", "6_of_clubs", "5_of_clubs", "4_of_clubs", "2_of_clubs"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cpu_deck.shuffle()
	_update_cpu_deck()

func _update_cpu_deck():
	if cpu_deck.size() == 0:
		$CPUDeckImage.visible = false
	$CPUDeckLabel.text = "CPU Deck: %d" % [cpu_deck.size()]

func draw_cpu_card():
	if cpu_deck.size() == 0:
		print("Empty cpu deck")
		return
	
	var card_drawn_name = cpu_deck[0]
	cpu_deck.erase(card_drawn_name)
	var card_image_path = "res://Assets/%s.png" %[card_drawn_name]
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.get_node("CardIMGback").texture = load("res://Assets/cardHachi.png")
	new_card.card_type = card_drawn_name
	new_card.get_node("CardIMGback").visible = true
	new_card.get_node("CardIMGfront").visible = false
	
	$"../CPUHand".add_card_to_cpu_hand(new_card)
	_update_cpu_deck()


# Called every frame. 'delta' is the elapsed time since the prev9ious frame.
func _process(delta: float) -> void:
	pass
