extends Control

@onready var screens: Dictionary[String, Node] = {
	"title_screen": $TitleScreenContainer,
	"stats_screen": $StatsScreenContainer,
	"settings_screen": $SettingsScreenContainer
}
@onready var screen_texts: Dictionary[String, Array] = {
	"title_screen": [],
	"stats_screen": [],
	"settings_screen": []
}
var text_controller
@onready var menu_text_scene = preload("res://scenes/menu/menu_text.tscn")

var current_screen = "title_screen"

# TITLE SCREEN
func setup_title_screen():
	pass
	
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
	var display_settings_container = $SettingsScreenContainer/DisplaySettingsContainer
	
	var resolution_button = $SettingsScreenContainer/DisplaySettingsContainer/ResolutionButton
	display_settings_container.move_child(resolution_button, 1)
	for resolution in Settings.RESOLUTIONS:
		resolution_button.add_item(resolution[0])
	var window_mode_button = $SettingsScreenContainer/DisplaySettingsContainer/WindowModeButton
	display_settings_container.move_child(window_mode_button, 3)
	for window_mode in Settings.WINDOW_MODES:
		window_mode_button.add_item(window_mode)
	var screen_button = $SettingsScreenContainer/DisplaySettingsContainer/ScreenButton
	display_settings_container.move_child(screen_button, 5)
	for screen in DisplayServer.get_screen_count():
		screen_button.add_item("Screen" + str(screen+1))
		
	# Label font style
	var display_settings_label = $SettingsScreenContainer/DisplaySettingsLabel
	display_settings_label.add_theme_font_size_override("font_size", 30)
	display_settings_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	
	var danger_zone_label = $SettingsScreenContainer/DangerZoneLabel
	danger_zone_label.add_theme_font_size_override("font_size", 30)
	danger_zone_label.add_theme_color_override("font_color", Color(1, 0.0, 0.0))
	
func _popup_resolution_button():
		var resolution_button = $SettingsScreenContainer/DisplaySettingsContainer/ResolutionButton
		resolution_button.show_popup()
	
func _popup_window_mode_button():
		var window_mode_button = $SettingsScreenContainer/DisplaySettingsContainer/WindowModeButton
		window_mode_button.show_popup()
		
func _popup_screen_button():
		var screen_button = $SettingsScreenContainer/DisplaySettingsContainer/ScreenButton
		screen_button.show_popup()
	
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

# TEXTS
func setup_texts():
	# TITLE SCREEN
	var start_new_run_func = Callable(self, "_on_start_new_run_button_pressed")
	var start_new_run_text = menu_text_scene.instantiate()
	var start_new_run_button = $TitleScreenContainer/StartNewRunButton
	start_new_run_button.add_child(start_new_run_text)
	start_new_run_text.initialize(text_controller, "Start New Run", start_new_run_func, 35, Vector2(0, 0))
	screen_texts["title_screen"].push_back(start_new_run_text)

	var statistics_func = Callable(self, "_on_statistics_button_pressed")
	var statistics_text = menu_text_scene.instantiate()
	var statistics_button = $TitleScreenContainer/StatisticsButton
	statistics_button.add_child(statistics_text)
	statistics_text.initialize(text_controller, "Statistics ", statistics_func, 35, Vector2(0, 0))
	screen_texts["title_screen"].push_back(statistics_text)

	var settings_func = Callable(self, "_on_settings_button_pressed")
	var settings_text = menu_text_scene.instantiate()
	var settings_button = $TitleScreenContainer/SettingsButton
	settings_button.add_child(settings_text)
	settings_text.initialize(text_controller, "Settings ", settings_func, 35, Vector2(0, 0))
	screen_texts["title_screen"].push_back(settings_text)

	var exit_func = Callable(self, "_on_exit_game_button_pressed")
	var exit_text = menu_text_scene.instantiate()
	var exit_game_button = $TitleScreenContainer/ExitGameButton
	exit_game_button.add_child(exit_text)
	exit_text.initialize(text_controller, "Exit Game", exit_func, 35, Vector2(0, 0))
	screen_texts["title_screen"].push_back(exit_text)
	
	# STATS SCREEN
	var return_func = Callable(self, "_on_return_button_pressed")
	var return_text_1 = menu_text_scene.instantiate()
	var return_button = $StatsScreenContainer/ReturnButton
	return_button.add_child(return_text_1)
	return_text_1.initialize(text_controller, "Return to Title Screen", return_func, 35, Vector2(0, 0))
	screen_texts["stats_screen"].push_back(return_text_1)
	
	# SETTINGS SCREEN	
	var return_text_2 = menu_text_scene.instantiate()
	var return_button_2 = $SettingsScreenContainer/ReturnButton
	return_button_2.add_child(return_text_2)
	return_text_2.initialize(text_controller, "Return to Title Screen", return_func, 35, Vector2(0, 0))
	screen_texts["settings_screen"].push_back(return_text_2)
	
	var display_settings_container = $SettingsScreenContainer/DisplaySettingsContainer
	
	for child in display_settings_container.get_children():
		if child.get_class() == "Node":
			display_settings_container.remove_child(child)
			child.queue_free()
	
	var resolution_func = Callable(self, "_popup_resolution_button")
	var resolution_text = menu_text_scene.instantiate()
	display_settings_container.add_child(resolution_text)
	display_settings_container.move_child(resolution_text, 0)
	resolution_text.initialize(text_controller, "Resolution ", resolution_func, 35, Vector2(0, 0))
	screen_texts["settings_screen"].push_back(resolution_text) 
	
	var window_mode_func = Callable(self, "_popup_window_mode_button")
	var window_mode_text = menu_text_scene.instantiate()
	display_settings_container.add_child(window_mode_text)
	display_settings_container.move_child(window_mode_text, 2)
	window_mode_text.initialize(text_controller, "Window Mode", window_mode_func, 35, Vector2(0, 0))
	screen_texts["settings_screen"].push_back(window_mode_text) 
	
	var screen_func = Callable(self, "_popup_screen_button")
	var screen_text = menu_text_scene.instantiate()
	display_settings_container.add_child(screen_text)
	display_settings_container.move_child(screen_text, 4)
	screen_text.initialize(text_controller, "Screen ", screen_func, 35, Vector2(0, 0))
	screen_texts["settings_screen"].push_back(screen_text) 
	
	var wipe_data_func = Callable(self, "_on_wipe_data_button_pressed")
	var wipe_data_text = menu_text_scene.instantiate()
	var wipe_data_button = $SettingsScreenContainer/WipeDataButton
	wipe_data_button.add_child(wipe_data_text)
	wipe_data_text.initialize(text_controller, "WIPE DATA", wipe_data_func, 35, Vector2(0, 0))
	screen_texts["settings_screen"].push_back(wipe_data_text)

	for child in display_settings_container.get_children():
		print(child.get_class())

func load_screen(screen: String):
	screens[current_screen].visible = false	
	
	match screen:
		"title_screen":
			screens["title_screen"].get_child(1).grab_focus()
		"stats_screen":
			screens["stats_screen"].get_child(0).grab_focus()
		"settings_screen":
			screens["settings_screen"].get_child(0).grab_focus()
			var resolution_button = $SettingsScreenContainer/DisplaySettingsContainer/ResolutionButton
			resolution_button.select(Settings.resolution)
			var window_mode_button = $SettingsScreenContainer/DisplaySettingsContainer/WindowModeButton
			window_mode_button.select(Settings.window_mode)
			var screen_button = $SettingsScreenContainer/DisplaySettingsContainer/ScreenButton
			screen_button.select(DisplayServer.window_get_current_screen())
	
	current_screen = screen
	screens[current_screen].visible = true
	text_controller.activate_texts(screen_texts[current_screen])

func _ready():
	text_controller = preload("res://scenes/menu/menu_text_controller.tscn").instantiate()
	add_child(text_controller)
	
	Settings.apply_all_settings()
	setup_title_screen()
	setup_settings_screen()	
	setup_stats_screen()
	setup_texts()
	load_screen("title_screen")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		load_screen("title_screen")
