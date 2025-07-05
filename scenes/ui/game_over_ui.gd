extends CanvasLayer

@onready var text_controller = $MenuTextController
@onready var menu_text_scene = preload("res://scenes/menu/menu_text.tscn")

var texts: Array[MenuText] = []

func _on_exit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _ready():
	# Exit button
	var exit_func = Callable(self, "_on_exit")
	var exit_text = menu_text_scene.instantiate()
	var exit_button = $Panel/ExitButton
	exit_button.add_child(exit_text)
	exit_text.initialize(text_controller, "Exit", exit_func, 35, Vector2(0, 0))
	texts.push_back(exit_text)
	
	text_controller.activate_texts(texts)
