extends Node
const SAVE_GAME_PATH = "user://savegame.tres"

var deck_to_save: Dictionary

func _save():
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	file.store_var(deck_to_save.duplicate())
	file.close()
	
func _load():
	if FileAccess.file_exists(SAVE_GAME_PATH):
		var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var save_data = data.duplicate()
		deck_to_save = save_data
		return true
	else:
		return null
