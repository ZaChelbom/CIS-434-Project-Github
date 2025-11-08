extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	SaveLoadManager.deck_to_save = $"..".deck
	SaveLoadManager._save()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
