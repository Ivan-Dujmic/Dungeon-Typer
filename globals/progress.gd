extends Node

var unlocked_dungeons: Array[String] = [
	"Crypts",
]

var unlocked_characters: Array[String] = [
	"Knight",
	"Wizard",
	"Vampire",
]

var runs_started: int = 0
var runs_completed: int = 0
var words_completed: int = 0
var characters_typed: int = 0
var enemies_defeated: int = 0
var items_used: int = 0

func get_stats() -> Dictionary:
	# Dictionaries do preserve insertion order when iterating
	return {
		"Runs started": runs_started,
		"Runs completed": runs_completed,
		"Words completed": words_completed,
		"Characters typed": characters_typed,
		"Enemies defeated": enemies_defeated,
		"Items used": items_used
	}

func wipe_data():
	runs_started = 0
	runs_completed = 0
	words_completed = 0
	characters_typed = 0
	enemies_defeated = 0
	items_used = 0
	
	unlocked_dungeons = [
		"Crypts"
	]
	
	unlocked_characters = [
		"Knight",
		"Wizard",
		"Vampire",
	]
