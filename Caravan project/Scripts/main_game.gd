extends Node2D

@onready var hand: Hand = $Hand
@onready var deck: Deck = $Deck
const CARAVAN_SCENE_PATH="res://Scenes/caravan.tscn"

func _ready() -> void:
	get_viewport().physics_object_picking_first_only = true
	get_viewport().physics_object_picking_sort = true
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


func _on_draw_card_button_pressed() -> void:
	var caravan_node = get_node("player_caravan_2")
	caravan_node.add_card_to_caravan()

func add_to_caravan():
	var caravan_node = get_node("player_caravan_2")
	caravan_node.add_card_to_caravan()
	pass

func _on_discard_card_button_pressed() -> void:
	hand._discard()


func _on_discard_tract_button_pressed() -> void:
	print("this will eventually discard a tract")


func _on_debug_reset_button_pressed() -> void:
	get_tree().reload_current_scene()
