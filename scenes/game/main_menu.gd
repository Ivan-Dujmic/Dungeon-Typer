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
	load_screen("title_screen")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		load_screen("title_screen")
