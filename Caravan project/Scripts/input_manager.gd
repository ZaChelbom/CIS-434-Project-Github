extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4

var card_manager_reference
var deck_reference

func _ready() -> void:
	card_manager_reference = $"../Card manager"
	deck_reference = $"../Deck"

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: #when you left click
		if event.is_pressed(): #when you click left click
			emit_signal("left_mouse_button_clicked")
			print("Clicked")
			raycast_at_cursor()
		else: #when you release left click
			emit_signal("left_mouse_button_released")
			print("Released")

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			#Card clicked
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			#Deck clicked
			print("deck clicked")
			deck_reference.draw_card()
		
			
