extends ScrollContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_v_scroll_bar().modulate = Color(0, 0, 0, 0)
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
