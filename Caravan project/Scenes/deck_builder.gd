extends Node2D

@onready var scroll_container1: ScrollContainer = $ScrollContainer
@onready var scroll_container2: ScrollContainer = $ScrollContainer2

var card_database_reference
var card_button
var card_name_array = [
	"2_of_",
	"3_of_",
	"4_of_",
	"5_of_",
	"6_of_",
	"7_of_",
	"8_of_",
	"9_of_",
	"10_of_",
	"jack_of_",
	"queen_of_",
	"king_of_",
	"ace_of_",
	]
	
var card_suit_array = ["clubs",
	"diamonds",
	"hearts",
	"spades"]
#const CARD_BUTTON_PATH = "res://Scenes/card_button.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_database_reference = preload("res://Scripts/card_database.gd")
	card_button = preload("res://Scenes/card_button.tscn")
	var new_button
	var card_image_path
	for k in 2: #0-1
		for i in 13: #0-12
			for j in 4: #0-3
				new_button = card_button.instantiate()
				card_image_path = str("res://Assets/" + card_name_array[i] + card_suit_array[j] + ".png")
				new_button.texture_normal = load(card_image_path)
				new_button.card = str(card_name_array[i] + card_suit_array[j])
				if k == 0:
					new_button.is_deck_button = false
					$ScrollContainer/VBoxContainer/GridContainer.add_child(new_button)
				else:
					new_button.is_deck_button = true
					$ScrollContainer2/VBoxContainer/GridContainer.add_child(new_button)
	
		new_button = card_button.instantiate()
		card_image_path = str("res://Assets/red_joker.png")
		new_button.texture_normal = load(card_image_path)
		new_button.card = "red_joker"
		if k == 0:
			new_button.is_deck_button = false
			$ScrollContainer/VBoxContainer/GridContainer.add_child(new_button)
		else:
			new_button.is_deck_button = true
			$ScrollContainer2/VBoxContainer/GridContainer.add_child(new_button)
	#pass # Replace with function body.
	scroll_container2.get_v_scroll_bar().mouse_filter = Control.MOUSE_FILTER_IGNORE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_container1.scroll_vertical -= 25
			scroll_container2.scroll_vertical -= 25
			print("Mouse wheel up")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_container1.scroll_vertical += 25
			scroll_container2.scroll_vertical += 25
			print("Mouse wheel down")
