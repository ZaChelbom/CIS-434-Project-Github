extends TextureButton

var card = ""
var number_of_cards = 6
var is_deck_button: bool
@onready var number_label = $number_label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	pass # Replace with function body.
	if number_of_cards > 0: #decrement label 
		number_of_cards -= 1
		number_label.text = "x%d" %[number_of_cards]
		print(card)
		if is_deck_button && number_of_cards == 0:
			#$".".disabled = true
			$".".modulate = Color(1,1,1,0)
		#add card to deck
	else:
		pass
	
