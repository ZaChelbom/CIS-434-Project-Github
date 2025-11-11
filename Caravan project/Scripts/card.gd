class_name Card
extends Node2D

signal card_clicked()
const SIZE := Vector2(88,132)

var card_type: String 
var is_in_hand: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and is_in_hand == true:
			
			
			card_clicked.emit(self)


func toggle_highlight():
	if $SelectionHighlight.visible == true:
		$SelectionHighlight.visible = false
	else:
		$SelectionHighlight.visible = true
