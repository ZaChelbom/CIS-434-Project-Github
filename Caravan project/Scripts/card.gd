class_name Card
extends Node2D

signal card_clicked()
signal validate_face_card()
signal remove_face_card_projection()

const SIZE := Vector2(88,132)

var card_name: String 
var value: int
var suit: String
var card_type: String # face or number card
var is_in_hand: bool
var is_projection: bool


func _ready() -> void:
	pass # Replace with function body.


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if is_in_hand == true:
				card_clicked.emit(self)
			elif is_projection == false:
				pass
				# emit signal to the caravan place the card


func toggle_highlight():
	if $SelectionHighlight.visible == true:
		$SelectionHighlight.visible = false
	else:
		$SelectionHighlight.visible = true


func _on_area_2d_mouse_entered() -> void:
	if is_in_hand == false and is_projection == false:
		validate_face_card.emit(self) # emit signal to project the placement of the face card


func _on_area_2d_mouse_exited() -> void:
	if is_in_hand == false and is_projection == false:
		remove_face_card_projection.emit()