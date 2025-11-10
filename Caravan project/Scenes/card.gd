class_name Card
extends Node2D

const SIZE := Vector2(88,132)

var card_type: String 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		print("Clicked")
	#if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		#print("Clicked")
	#pass # Replace with function body.
