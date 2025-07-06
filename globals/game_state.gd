extends Node

var dungeon = "Crypts"
var character = "Knight"
var difficulty = 10

var modifier_roll_amount = 3
var boss_active = false

var run_words_completed = 0
var run_characters_typed = 0
var run_enemies_defeated = 0
var run_items_used = 0

func start_run():
	modifier_roll_amount = 3
	boss_active = false
	
	run_words_completed = 0
	run_characters_typed = 0
	run_enemies_defeated = 0
	run_items_used = 0

func get_run_stats():
	return {
		"Words Completed": run_words_completed,
		"Characters Typed": run_characters_typed,
		"Enemies Defeated": run_enemies_defeated,
		"Items Used": run_items_used
	}
	
func add_run_stats_to_all_time_stats(victory: bool):
	Progress.runs_started += 1
	Progress.runs_completed += (1 if victory else 0)
	Progress.words_completed += run_words_completed
	Progress.characters_typed += run_characters_typed
	Progress.enemies_defeated += run_enemies_defeated
	Progress.items_used += run_items_used
