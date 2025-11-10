extends Node2D

@onready var hand: Hand = $Hand
@onready var deck: Deck = $Deck

func _ready() -> void:
	deck.load_deck()
	for i in 8: # draw 8 cards from deck on startup
		deck.draw_card()


func _on_draw_card_button_pressed() -> void:
	deck.draw_card()


func _on_discard_card_button_pressed() -> void:
	hand._discard()


func _on_discard_tract_button_pressed() -> void:
	print("this will eventually discard a tract")


func _on_debug_reset_button_pressed() -> void:
	get_tree().reload_current_scene()
