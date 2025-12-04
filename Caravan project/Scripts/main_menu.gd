extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var play_button = get_node("CenterContainer/MainButtons/Play")
	if SaveLoadManager._load() == null:
		play_button.disabled = true
	else:
		play_button.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn") # Replace with function body.


func _on_build_deck_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/deck_builder.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
