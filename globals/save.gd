extends Node

const SAVE_PATH := "user://save.json"

func _ready():	# Automatically runs when the game starts
	load_game()

func save_game():
	var data = {
		"unlocked_dungeons": Progress.unlocked_dungeons,
		"unlocked_characters": Progress.unlocked_characters,
		"runs_started": Progress.runs_started,
		"runs_completed": Progress.runs_completed,
		"words_completed": Progress.words_completed,
		"characters_typed": Progress.characters_typed,
		"enemies_defeated": Progress.enemies_defeated,
		"items_used": Progress.items_used,
		
		"window_mode": Settings.window_mode,
		"resolution": Settings.resolution,
		"screen": Settings.screen,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return # No save to load

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return # Malformed or corrupted

	Progress.unlocked_dungeons = force_string_array(data.get("unlocked_dungeons", []))
	Progress.unlocked_characters = force_string_array(data.get("unlocked_characters", []))
	Progress.runs_started = data.get("runs_started", 0)
	Progress.runs_completed = data.get("runs_completed", 0)
	Progress.words_completed = data.get("words_completed", 0)
	Progress.characters_typed = data.get("characters_typed", 0)
	Progress.enemies_defeated = data.get("enemies_defeated", 0)
	Progress.items_used = data.get("items_used", 0)
	
	Settings.window_mode = data.get("window_mode", 0)
	Settings.resolution = data.get("resolution", 2)
	Settings.screen = data.get("screen", 1)

func force_string_array(arr) -> Array[String]:
	var result: Array[String] = []
	for item in arr:
		if typeof(item) == TYPE_STRING:
			result.append(item)
	return result
