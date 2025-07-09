extends Control

@onready var screens: Dictionary[String, Node] = {
	"title_screen": $TitleScreenContainer,
	"dungeon_select_screen": $DungeonSelectScreenContainer,
	"character_select_screen": $CharacterSelectScreenContainer,
	"difficulty_select_screen": $DifficultySelectScreenContainer,
	"stats_screen": $StatsScreenContainer,
	"settings_screen": $SettingsScreenContainer
}
var current_screen = "title_screen"

@onready var texts: Dictionary[String, Array] = {
	"title_screen": [],
	"dungeon_select_screen": [],
	"character_select_screen": [],
	"difficulty_select_screen": [],
	"stats_screen": [],
	"settings_screen": [],
	"wipe_data_dialog": []
}
@onready var text_controller = $TextController
@onready var menu_text_scene = preload("res://scenes/menu/menu_text.tscn")

@onready var dungeon_previews: Dictionary = {}
@onready var character_previews: Dictionary = {}

@onready var button_font = preload("res://assets/fonts/ia-writer-mono-latin-700-normal.ttf")

# TITLE SCREEN
func setup_title_screen():
	pass
	
func _on_start_new_run_button_pressed() -> void:
	load_screen("dungeon_select_screen")
	
func _on_statistics_button_pressed() -> void:
	load_screen("stats_screen")
	
func _on_settings_button_pressed() -> void:
	load_screen("settings_screen")
	
func _on_exit_game_button_pressed() -> void:
	get_tree().quit()
	
# RETURN BUTTON
func _on_return_button_pressed() -> void:
	load_screen("title_screen")

func _on_return_button_to_dungeon_pressed() -> void:
	load_screen("dungeon_select_screen")
	
func _on_return_button_to_character_pressed() -> void:
	load_screen("character_select_screen")
	
# DUNGEON SELECT
func setup_dungeon_select_screen():
	# Load preview images
	for dungeon_name in Progress.unlocked_dungeons:
		var folder = dungeon_name.to_lower().replace(" ", "_")
		dungeon_previews[dungeon_name] = load("res://assets/textures/dungeons/%s/preview.png" % folder)
		
	var container = $DungeonSelectScreenContainer
	
	for dungeon in dungeon_previews.keys():
		# BUTTON
		var button = Button.new()
		button.custom_minimum_size = Vector2(400, 330)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_font_override("font", button_font)
		button.add_theme_font_size_override("font_size", 35)
		button.pressed.connect(func(): _on_select_dungeon(dungeon))

		# IMAGE
		var texture_rect = TextureRect.new()
		texture_rect.texture = dungeon_previews[dungeon]
		texture_rect.expand = true
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.anchor_right = 1.0
		texture_rect.anchor_bottom = 1.0
		texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.add_child(texture_rect)

		# MT
		var mt = menu_text_scene.instantiate()
		button.add_child(mt)
		mt.initialize(text_controller, dungeon, Callable(self, "_on_select_dungeon").bind(dungeon), 35, Vector2(0, 0))
		mt.anchor_left = 0.0
		mt.anchor_right = 1.0
		mt.anchor_top = 1.0
		mt.anchor_bottom = 1.0
		mt.offset_left = 0
		mt.offset_right = 0
		mt.offset_bottom = -10
		mt.offset_top = -50
		mt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mt.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		texts["dungeon_select_screen"].push_back(mt)
		container.add_child(button)
	
	# Locked dungeons
	for dungeon in Constants.dungeons:
		if dungeon not in Progress.unlocked_dungeons:
			# BUTTON (disabled)
			var button = Button.new()
			button.custom_minimum_size = Vector2(400, 330)
			button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			button.add_theme_font_override("font", button_font)
			button.add_theme_font_size_override("font_size", 35)

			# IMAGE
			var texture_rect = TextureRect.new()
			texture_rect.texture = load("res://assets/textures/dungeons/locked_dungeon_preview.png")
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.anchor_right = 1.0
			texture_rect.anchor_bottom = 1.0
			texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
			button.add_child(texture_rect)
			
			container.add_child(button)

func _on_select_dungeon(dungeon: String):
	GameState.dungeon = dungeon
	load_screen("character_select_screen")
	
func _wipe_dungeon_unlocks():
	# Everything except return button
	for i in range(1, len(texts["dungeon_select_screen"])):
		text_controller.detach(texts["dungeon_select_screen"][i])
	texts["dungeon_select_screen"] = texts["dungeon_select_screen"].slice(0, 1)
	
	dungeon_previews = {}
	
	var container = $DungeonSelectScreenContainer
	for child in container.get_children():
		if child is Button:
			if child.name != "ReturnButton":
				container.remove_child(child)
				child.queue_free()
	
	setup_dungeon_select_screen()
	
# CHARACTER SELECT
func setup_character_select_screen():
	# Load preview images
	for character_name in Progress.unlocked_characters:
		var folder = character_name.to_lower().replace(" ", "_")
		character_previews[character_name] = load("res://assets/textures/entities/player/%s/preview.png" % folder)
		
	var container = $CharacterSelectScreenContainer/CharactersContainer
	
	for character in character_previews.keys():
		# BUTTON
		var button = Button.new()
		button.custom_minimum_size = Vector2(128, 210)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.add_theme_font_override("font", button_font)
		button.add_theme_font_size_override("font_size", 30)
		button.pressed.connect(func(): _on_select_character(character))

		# IMAGE
		var texture_rect = TextureRect.new()
		texture_rect.texture = character_previews[character]
		texture_rect.expand = true
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.anchor_right = 1.0
		texture_rect.anchor_bottom = 1.0
		texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.add_child(texture_rect)

		# MT
		var mt = menu_text_scene.instantiate()
		button.add_child(mt)
		mt.initialize(text_controller, character, Callable(self, "_on_select_character").bind(character), 30, Vector2(0, 0))
		mt.anchor_left = 0.0
		mt.anchor_right = 1.0
		mt.anchor_top = 1.0
		mt.anchor_bottom = 1.0
		mt.offset_left = 0
		mt.offset_right = 0
		mt.offset_bottom = -10
		mt.offset_top = -50
		mt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mt.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		texts["character_select_screen"].push_back(mt)
		container.add_child(button)
		
	# Locked dungeons
	for character in Constants.characters:
		if character not in Progress.unlocked_characters:
			# BUTTON (disabled)
			var button = Button.new()
			button.custom_minimum_size = Vector2(128, 210)
			button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			button.add_theme_font_override("font", button_font)
			button.add_theme_font_size_override("font_size", 30)

			# IMAGE
			var texture_rect = TextureRect.new()
			texture_rect.texture = load("res://assets/textures/entities/player/locked_character_preview.png")
			texture_rect.expand = true
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.anchor_right = 1.0
			texture_rect.anchor_bottom = 1.0
			texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
			button.add_child(texture_rect)
			
			container.add_child(button)
	
func _on_select_character(character: String):
	GameState.character = character
	load_screen("difficulty_select_screen")
	
func _wipe_character_unlocks():
	# Everything except return button
	for i in range(1, len(texts["character_select_screen"])):
		text_controller.detach(texts["character_select_screen"][i])
	texts["character_select_screen"] = texts["character_select_screen"].slice(0, 1)
	
	character_previews = {}
	
	var container = $CharacterSelectScreenContainer/CharactersContainer
	for child in container.get_children():
		if child is Button:
			child.queue_free()
			container.remove_child(child)
		
	setup_character_select_screen()
	
# DIFFICULTY SELECT
func setup_difficulty_select_screen():
	var difficulty_box = $DifficultySelectScreenContainer/DifficultyBox
	difficulty_box.value = GameState.difficulty
	difficulty_box.value_changed.connect(_on_select_difficulty)
	
func focus_difficulty_box():
	var difficulty_box = $DifficultySelectScreenContainer/DifficultyBox
	difficulty_box.get_line_edit().grab_focus()
	
func _on_select_difficulty(difficulty: int):
	GameState.difficulty = difficulty
	
func _on_start_run_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
	
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
	
	# Wipe data dialog custom buttons
	var wipe_data_dialog = $SettingsScreenContainer/WipeDataDialog
	var cancel_button = wipe_data_dialog.get_cancel_button()
	var ok_button = wipe_data_dialog.get_ok_button()
	ok_button.custom_minimum_size = Vector2(200, 100)
	cancel_button.custom_minimum_size = Vector2(200, 100)
	ok_button.text = "         "
	cancel_button.text = "       "
	ok_button.size_flags_horizontal = SIZE_SHRINK_CENTER
	cancel_button.size_flags_horizontal = SIZE_SHRINK_CENTER
	ok_button.add_theme_font_override("font", button_font)
	cancel_button.add_theme_font_override("font", button_font)
	ok_button.add_theme_font_size_override("font_size", 20)
	cancel_button.add_theme_font_size_override("font_size", 20)
	
	wipe_data_dialog.text_controller = text_controller
	
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
	var ok_button = wipe_data_dialog.get_ok_button()
	var cancel_button = wipe_data_dialog.get_cancel_button()
	cancel_button.grab_focus()
	
	var wipe_data_ok_func = Callable(self, "_confirm_wipe_data_dialog")
	var wipe_data_ok_text = menu_text_scene.instantiate()
	ok_button.add_child(wipe_data_ok_text)
	wipe_data_ok_text.initialize(text_controller, "WIPE DATA", wipe_data_ok_func, 20, Vector2(0, 0))
	texts["wipe_data_dialog"].push_back(wipe_data_ok_text)

	var wipe_data_cancel_func = Callable(self, "_cancel_wipe_data_dialog")
	var wipe_data_cancel_text = menu_text_scene.instantiate()
	cancel_button.add_child(wipe_data_cancel_text)
	wipe_data_cancel_text.initialize(text_controller, "Cancel", wipe_data_cancel_func, 20, Vector2(0, 0))
	texts["wipe_data_dialog"].push_back(wipe_data_cancel_text)

	text_controller.activate_texts(texts["wipe_data_dialog"])
	
func _on_wipe_data_dialog_canceled() -> void:
	text_controller.activate_texts(texts["settings_screen"])
	for tt in texts["wipe_data_dialog"]:
		text_controller.detach(tt)
		tt.queue_free()
	texts["wipe_data_dialog"].clear()
	
func _on_confirmation_dialog_confirmed() -> void:
	Progress.wipe_data()
	setup_stats_screen()
	text_controller.activate_texts(texts["settings_screen"])
	for tt in texts["wipe_data_dialog"]:
		text_controller.detach(tt)
		tt.queue_free()
	texts["wipe_data_dialog"].clear()
	_wipe_dungeon_unlocks()
	_wipe_character_unlocks()
	
func _confirm_wipe_data_dialog():
	var wipe_data_dialog = $SettingsScreenContainer/WipeDataDialog
	wipe_data_dialog.hide()
	_on_confirmation_dialog_confirmed()
	
func _cancel_wipe_data_dialog():
	var wipe_data_dialog = $SettingsScreenContainer/WipeDataDialog
	wipe_data_dialog.hide()
	_on_wipe_data_dialog_canceled()

# TEXTS
func setup_texts():
	# TITLE SCREEN
	var start_new_run_func = Callable(self, "_on_start_new_run_button_pressed")
	var start_new_run_text = menu_text_scene.instantiate()
	var start_new_run_button = $TitleScreenContainer/StartNewRunButton
	start_new_run_button.add_child(start_new_run_text)
	start_new_run_text.initialize(text_controller, "Start New Run", start_new_run_func, 35, Vector2(0, 0))
	texts["title_screen"].push_back(start_new_run_text)

	var statistics_func = Callable(self, "_on_statistics_button_pressed")
	var statistics_text = menu_text_scene.instantiate()
	var statistics_button = $TitleScreenContainer/StatisticsButton
	statistics_button.add_child(statistics_text)
	statistics_text.initialize(text_controller, "Statistics", statistics_func, 35, Vector2(0, 0))
	texts["title_screen"].push_back(statistics_text)

	var settings_func = Callable(self, "_on_settings_button_pressed")
	var settings_text = menu_text_scene.instantiate()
	var settings_button = $TitleScreenContainer/SettingsButton
	settings_button.add_child(settings_text)
	settings_text.initialize(text_controller, "Settings", settings_func, 35, Vector2(0, 0))
	texts["title_screen"].push_back(settings_text)

	var exit_func = Callable(self, "_on_exit_game_button_pressed")
	var exit_text = menu_text_scene.instantiate()
	var exit_game_button = $TitleScreenContainer/ExitGameButton
	exit_game_button.add_child(exit_text)
	exit_text.initialize(text_controller, "Exit Game", exit_func, 35, Vector2(0, 0))
	texts["title_screen"].push_back(exit_text)
	
	# DUNGEON SELECT SCREEN
	var return_func = Callable(self, "_on_return_button_pressed")
	var return_text_3 = menu_text_scene.instantiate()
	var return_button_3 = $DungeonSelectScreenContainer/ReturnButton
	return_button_3.add_child(return_text_3)
	return_text_3.initialize(text_controller, "Return to Title Screen", return_func, 35, Vector2(0, 0))
	texts["dungeon_select_screen"].push_back(return_text_3)
	
	# CHARACTER SELECT SCREEN
	var return_func_to_dungeon = Callable(self, "_on_return_button_to_dungeon_pressed")
	var return_text_4 = menu_text_scene.instantiate()
	var return_button_4 = $CharacterSelectScreenContainer/ReturnButton
	return_button_4.add_child(return_text_4)
	return_text_4.initialize(text_controller, "Return to Dungeon Screen", return_func_to_dungeon, 35, Vector2(0, 0))
	texts["character_select_screen"].push_back(return_text_4)
	
	# DIFFICULTY SELECT SCREEN
	var return_func_to_character = Callable(self, "_on_return_button_to_character_pressed")
	var return_text_5 = menu_text_scene.instantiate()
	var return_button_5 = $DifficultySelectScreenContainer/ReturnButton
	return_button_5.add_child(return_text_5)
	return_text_5.initialize(text_controller, "Return to Character Screen", return_func_to_character, 35, Vector2(0, 0))
	texts["difficulty_select_screen"].push_back(return_text_5)
	
	var focus_difficulty_box_func = Callable(self, "focus_difficulty_box")
	var focus_difficulty_box_text = menu_text_scene.instantiate()
	var difficulty_screen_container = $DifficultySelectScreenContainer
	difficulty_screen_container.add_child(focus_difficulty_box_text)
	difficulty_screen_container.move_child(focus_difficulty_box_text, 2)
	focus_difficulty_box_text.initialize(text_controller, "Difficulty", focus_difficulty_box_func, 35, Vector2(0, 0))
	texts["difficulty_select_screen"].push_back(focus_difficulty_box_text)
	focus_difficulty_box_text.custom_minimum_size.x = 250
	focus_difficulty_box_text.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var start_run_func = Callable(self, "_on_start_run_button_pressed")
	var start_run_text = menu_text_scene.instantiate()
	var start_run_button = $DifficultySelectScreenContainer/StartRunButton
	start_run_button.add_child(start_run_text)
	start_run_text.initialize(text_controller, "Start Run", start_run_func, 35, Vector2(0, 0))
	texts["difficulty_select_screen"].push_back(start_run_text)
	
	# STATS SCREEN
	var return_text_1 = menu_text_scene.instantiate()
	var return_button_1 = $StatsScreenContainer/ReturnButton
	return_button_1.add_child(return_text_1)
	return_text_1.initialize(text_controller, "Return to Title Screen", return_func, 35, Vector2(0, 0))
	texts["stats_screen"].push_back(return_text_1)
	
	# SETTINGS SCREEN	
	var return_text_2 = menu_text_scene.instantiate()
	var return_button_2 = $SettingsScreenContainer/ReturnButton
	return_button_2.add_child(return_text_2)
	return_text_2.initialize(text_controller, "Return to Title Screen", return_func, 35, Vector2(0, 0))
	texts["settings_screen"].push_back(return_text_2)
	
	var display_settings_container = $SettingsScreenContainer/DisplaySettingsContainer
	
	for child in display_settings_container.get_children():
		if child.get_class() == "Node":
			display_settings_container.remove_child(child)
			child.queue_free()
	
	var resolution_func = Callable(self, "_popup_resolution_button")
	var resolution_text = menu_text_scene.instantiate()
	display_settings_container.add_child(resolution_text)
	display_settings_container.move_child(resolution_text, 0)
	resolution_text.initialize(text_controller, "Resolution", resolution_func, 35, Vector2(0, 0))
	texts["settings_screen"].push_back(resolution_text) 
	
	var window_mode_func = Callable(self, "_popup_window_mode_button")
	var window_mode_text = menu_text_scene.instantiate()
	display_settings_container.add_child(window_mode_text)
	display_settings_container.move_child(window_mode_text, 2)
	window_mode_text.initialize(text_controller, "Window Mode", window_mode_func, 35, Vector2(0, 0))
	texts["settings_screen"].push_back(window_mode_text) 
	
	var screen_func = Callable(self, "_popup_screen_button")
	var screen_text = menu_text_scene.instantiate()
	display_settings_container.add_child(screen_text)
	display_settings_container.move_child(screen_text, 4)
	screen_text.initialize(text_controller, "Screen", screen_func, 35, Vector2(0, 0))
	texts["settings_screen"].push_back(screen_text) 
	
	var wipe_data_func = Callable(self, "_on_wipe_data_button_pressed")
	var wipe_data_text = menu_text_scene.instantiate()
	var wipe_data_button = $SettingsScreenContainer/WipeDataButton
	wipe_data_button.add_child(wipe_data_text)
	wipe_data_text.initialize(text_controller, "WIPE DATA", wipe_data_func, 35, Vector2(0, 0))
	texts["settings_screen"].push_back(wipe_data_text)

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
		"dungeon_select_screen":
			screens["dungeon_select_screen"].get_child(0).grab_focus()
		"character_select_screen":
			screens["character_select_screen"].get_child(0).grab_focus()
		"difficulty_select_screen":
			screens["difficulty_select_screen"].get_child(0).grab_focus()
	
	current_screen = screen
	screens[current_screen].visible = true
	text_controller.activate_texts(texts[current_screen])

func _ready():
	Settings.apply_all_settings()
	
	setup_texts()
	
	setup_title_screen()
	setup_dungeon_select_screen()
	setup_character_select_screen()
	setup_difficulty_select_screen()
	setup_settings_screen()	
	setup_stats_screen()
	
	load_screen("title_screen")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		load_screen("title_screen")
