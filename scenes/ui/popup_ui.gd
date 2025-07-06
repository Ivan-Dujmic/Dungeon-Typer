extends CanvasLayer

@onready var game = get_node("/root/Game")
@onready var text_controller = $MenuTextController
@onready var menu_text_scene = preload("res://scenes/menu/menu_text.tscn")

@onready var panels: Dictionary[String, Node] = {
	"game_over": $GameOverPanel,
	"modifier": $ModifierPanel
}
var current_panel = ""

@onready var texts: Dictionary[String, Array] = {
	"game_over": [],
	"modifier": [],
	"": []
}

# So they don't go out of scope and become null
var effects: Dictionary[Node, Resource] = {}

func _on_exit_game_menu(_caller):
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
	var game_over_exit_func = Callable(self, "_on_exit_game_menu")
	var game_over_exit_text = menu_text_scene.instantiate()
	var game_over_exit_button = $GameOverPanel/ExitButton
	game_over_exit_button.add_child(game_over_exit_text)
	game_over_exit_text.initialize(text_controller, "Exit", game_over_exit_func, 35, Vector2(0, 0))
	texts["game_over"].push_back(game_over_exit_text)
	
	# MODIFIER PANEL
	var skip_func = Callable(self, "_skip_modifier")
	var skip_text = menu_text_scene.instantiate()
	var skip_button = $ModifierPanel/SkipButton
	skip_button.add_child(skip_text)
	skip_text.initialize(text_controller, "Skip", skip_func, 35, Vector2(0, 0))
	texts["modifier"].push_back(skip_text)

func load_panel(panel: String):
	if current_panel != "":
		panels[current_panel].visible = false
		
	match panel:
		"":
			get_tree().paused = false
		"game_over":
			panels["game_over"].get_child(2).grab_focus()
		"modifier":
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
				
			# Other
			modifiers.get_child(0).grab_focus()
		
	current_panel = panel
	text_controller.activate_texts(texts[current_panel])
	if current_panel != "":
		panels[current_panel].visible = true

func _ready():
	setup_texts()
	
	load_panel("")
