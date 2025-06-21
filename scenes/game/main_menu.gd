extends Control

@onready var screens: Dictionary[String, Node] = {
	"title_screen": $TitleScreenContainer,
	"stats_screen": $StatsScreenContainer,
	"settings_screen": $SettingsScreenContainer
}

var current_screen = "title_screen"

# TITLE SCREEN
func _on_start_new_run_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
func _on_statistics_button_pressed() -> void:
	load_screen("stats_screen")
func _on_settings_button_pressed() -> void:
	load_screen("settings_screen")
func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
	
# STATS AND SETTINGS
func _on_return_button_pressed() -> void:
	load_screen("title_screen")
	
# STATS
func setup_stats_screen():
	var stats = Progress.get_stats()

	var grid = $StatsScreenContainer/StatsContainer
	
	for child in grid.get_children():
		child.queue_free()

	var index = 0
	
	for stat in stats.keys():
		var name_label = Label.new()
		name_label.text = stat
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 30)

		var value_label = Label.new()
		value_label.text = str(stats[stat])
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.add_theme_font_size_override("font_size", 30)
		
		match index % 2:
			0:
				name_label.add_theme_color_override("font_color", Color(0.871, 0.401, 0.0))
				value_label.add_theme_color_override("font_color", Color(0.871, 0.401, 0.0))
			1:
				name_label.add_theme_color_override("font_color", Color(0.971, 0.601, 0.1))
				value_label.add_theme_color_override("font_color", Color(0.971, 0.601, 0.1))

		grid.add_child(name_label)
		grid.add_child(value_label)
		
		index += 1
		 
# SETTINGS
func setup_settings_screen():
	var resolution_button = $SettingsScreenContainer/ResolutionButton
	for resolution in Settings.RESOLUTIONS:
		resolution_button.add_item(resolution[0])
	var window_mode_button = $SettingsScreenContainer/WindowModeButton
	for window_mode in Settings.WINDOW_MODES:
		window_mode_button.add_item(window_mode)
	var screen_button = $SettingsScreenContainer/ScreenButton
	for screen in DisplayServer.get_screen_count():
		screen_button.add_item("Screen " + str(screen+1))
	# Label font style
	for child in screens["settings_screen"].get_children():
		if child is Label:
			child.add_theme_font_size_override("font_size", 30)
			child.add_theme_color_override("font_color", Color(0.871, 0.401, 0.0))
	
func _on_resolution_button_item_selected(index: int) -> void:
	Settings.set_resolution(index)
func _on_window_mode_button_item_selected(index: int) -> void:
	Settings.set_window_mode(index)
func _on_screen_button_item_selected(index: int) -> void:
	Settings.set_screen(index)
func _on_wipe_data_button_pressed() -> void:
	var wipe_data_dialog = $SettingsScreenContainer/WipeDataDialog
	wipe_data_dialog.popup_centered()
func _on_confirmation_dialog_confirmed() -> void:
	Progress.wipe_data()
	setup_stats_screen()

func load_screen(screen: String):
	screens[current_screen].visible = false
	
	match screen:
		"title_screen":
			screens["title_screen"].get_child(1).grab_focus()
		"stats_screen":
			screens["stats_screen"].get_child(0).grab_focus()
		"settings_screen":
			screens["settings_screen"].get_child(0).grab_focus()
			var resolution_button = $SettingsScreenContainer/ResolutionButton
			resolution_button.select(Settings.resolution)
			var window_mode_button = $SettingsScreenContainer/WindowModeButton
			window_mode_button.select(Settings.window_mode)
			var screen_button = $SettingsScreenContainer/ScreenButton
			screen_button.select(DisplayServer.window_get_current_screen())
	
	screens[screen].visible = true
	current_screen = screen

func _ready():
	Settings.apply_all_settings()
	setup_settings_screen()	
	setup_stats_screen()
	load_screen("title_screen")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		load_screen("title_screen")
