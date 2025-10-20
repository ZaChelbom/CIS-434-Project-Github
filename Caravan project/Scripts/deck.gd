extends Node2D

var player_deck = ["2_of_clubs","7_of_diamonds","ace_of_spades","7_of_diamonds","7_of_spades", "3_of_clubs", "4_of_hearts" ,"king_of_spades"]
var card_database_reference

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print($Area2D.collision_mask)
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://Scripts/card_database.gd")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func draw_card():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
		
	$RichTextLabel.text = str(player_deck.size())
	print("draw card")
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://Assets/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("Value").text = str(card_database_reference.CARDS[card_drawn_name][0])
	$"../Card manager".add_child(new_card)
	new_card.name = "Card"
	$"../Player hand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")
