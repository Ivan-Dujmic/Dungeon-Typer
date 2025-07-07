extends CanvasLayer

@onready var game = get_node("/root/Game")
@onready var text_controller = $MenuTextController
@onready var menu_text_scene = preload("res://scenes/menu/menu_text.tscn")

@onready var panels: Dictionary[String, Node] = {
	"game_over": $GameOverPanel,
	"victory": $VictoryPanel,
	"modifier": $ModifierPanel
}
var current_panel = ""

@onready var texts: Dictionary[String, Array] = {
	"game_over": [],
	"victory": [],
	"modifier": [],
	"": []
}

# So they don't go out of scope and become null
var effects: Dictionary[Node, Resource] = {}

func _on_exit_game(_caller):
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _choose_modifier(caller):
	var effect
	if caller is MenuText:
		effect = effects[caller]
	elif caller is Button:
		effect = effects[caller.get_child(0).get_child(0)]
	effect.execute(game)
	load_panel("")

func _skip_modifier(_caller):
	load_panel("")

func setup_texts():
	# GAME OVER PANEL
	var game_over_exit_func = Callable(self, "_on_exit_game")
	var game_over_exit_text = menu_text_scene.instantiate()
	var game_over_exit_button = $GameOverPanel/ExitButton
	game_over_exit_button.add_child(game_over_exit_text)
	game_over_exit_text.initialize(text_controller, "Exit", game_over_exit_func, 35, Vector2(0, 0))
	texts["game_over"].push_back(game_over_exit_text)
	game_over_exit_button.pressed.connect(func(): _on_exit_game(game_over_exit_button))
	
	# VICTORY PANEL
	var victory_exit_text = menu_text_scene.instantiate()
	var victory_exit_button = $VictoryPanel/ExitButton
	victory_exit_button.add_child(victory_exit_text)
	victory_exit_text.initialize(text_controller, "Exit", game_over_exit_func, 35, Vector2(0, 0))
	texts["victory"].push_back(victory_exit_text)
	victory_exit_button.pressed.connect(func(): _on_exit_game(victory_exit_button))
	
	# MODIFIER PANEL
	var skip_func = Callable(self, "_skip_modifier")
	var skip_text = menu_text_scene.instantiate()
	var skip_button = $ModifierPanel/SkipButton
	skip_button.add_child(skip_text)
	skip_text.initialize(text_controller, "Skip", skip_func, 35, Vector2(0, 0))
	texts["modifier"].push_back(skip_text)

func setup_modifier_panel():
	# Delete previous modifier texts (only modifier texts) and effects array
	for i in range(1, len(texts["modifier"])):
		var text = texts["modifier"][i]
		text_controller.detach(text)
	texts["modifier"] = texts["modifier"].slice(0, 1)
	effects.clear()
	var modifiers = $ModifierPanel/Modifiers
	for child in modifiers.get_children():
		child.queue_free()
	
	# Roll and make modifier buttons
	var rolls = Constants.roll_modifiers(game, GameState.modifier_roll_amount)
	panels["modifier"].custom_minimum_size.x = max(330, 225 * len(rolls) + 5)
	for roll in rolls:
		var button = Button.new()
		modifiers.add_child(button)
		button.pressed.connect(func(): _choose_modifier(button))
		button.custom_minimum_size = Vector2(220, 300)
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		var v_box_cont = VBoxContainer.new()
		v_box_cont.custom_minimum_size.x = button.custom_minimum_size.x
		v_box_cont.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v_box_cont.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		v_box_cont.alignment = BoxContainer.ALIGNMENT_BEGIN
		button.add_child(v_box_cont)
		
		var effect = roll.effect_command.new()
		var mt_func = Callable(self, "_choose_modifier")
		var mt = menu_text_scene.instantiate()
		effects[mt] = effect
		v_box_cont.add_child(mt)
		mt.initialize(text_controller, roll.name, mt_func, 20, Vector2(0, 0))
		mt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mt.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		mt.fit_content = true
		texts["modifier"].push_back(mt)
		
		var texture_rect = TextureRect.new()
		v_box_cont.add_child(texture_rect)
		var modifier_name = roll.name.to_lower().replace(" ", "_")
		texture_rect.texture = load("res://assets/textures/modifiers/%s.png" % modifier_name)
		texture_rect.custom_minimum_size = Vector2(128, 128)
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		var description = Label.new()
		v_box_cont.add_child(description)
		description.text = roll.description
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
	# Focus
	modifiers.get_child(0).grab_focus()

func fill_grid_with_stats(grid: GridContainer):
	var stats = GameState.get_run_stats()
	
	var index = 0
	
	for stat in stats.keys():
		var name_label = Label.new()
		name_label.text = stat
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 24)

		var value_label = Label.new()
		value_label.text = str(stats[stat])
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.add_theme_font_size_override("font_size", 24)
		
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

func load_panel(panel: String):
	if current_panel != "":
		panels[current_panel].visible = false
		
	match panel:
		"":
			get_tree().paused = false
		"game_over":
			var grid = $GameOverPanel/StatsContainer
			fill_grid_with_stats(grid)
			panels["game_over"].get_child(2).grab_focus()
		"victory":
			var grid = $VictoryPanel/StatsContainer
			fill_grid_with_stats(grid)
			panels["victory"].get_child(2).grab_focus()
		"modifier":
			setup_modifier_panel()
		
	current_panel = panel
	text_controller.activate_texts(texts[current_panel])
	if current_panel != "":
		panels[current_panel].visible = true

func _ready():
	setup_texts()
	
	load_panel("")
