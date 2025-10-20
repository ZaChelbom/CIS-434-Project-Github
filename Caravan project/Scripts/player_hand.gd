extends Node2D

#const HAND_COUNT = 8
#936 x 
#394 y
const CARD_WIDTH = 50
const HAND_Y_POSITION = 394
const DEFAULT_CARD_MOVE_SPEED = 0.1
var player_hand = []
var starting_x
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#starting_x = get_viewport().size.x / 2
	starting_x = 936
	

func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, speed)

func update_hand_positions(speed):
	for i in range(player_hand.size()):
		#Get new card position based on index
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(index):
	#later change total width to x offset  #and change x_position to x_position
	var x_offset = (player_hand.size() -1) * CARD_WIDTH
	var x_position = starting_x + index * CARD_WIDTH - x_offset / 2
	return x_position


func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)
	
func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
