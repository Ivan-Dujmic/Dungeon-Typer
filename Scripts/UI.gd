extends CanvasLayer

@onready var text_controller = get_node("/root/Game/TextController")

var font = load("res://Fonts/ia-writer-mono-latin-400-normal.ttf")

var attached_tt_list: Array[TypingText]

func movement_tt_setup():
	var player = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player")
	
	# Preload forward movement typing text
	var tt_move_forward = preload("res://Scenes/TypingText.tscn").instantiate()
	add_child(tt_move_forward)
	# Calculate position so that the next typed letter is just after the half screen point
	
	var size = font.get_string_size("A".repeat(2 * 26), HORIZONTAL_ALIGNMENT_LEFT, -1, 49)
	var position = Vector2((get_viewport().size.x - size.x) / 2, 875)
	# Function to be called by TypingText on word complete
	var on_word_complete_forward_func = Callable(self, "_on_word_complete_forward").bind(player)
	# Initalize
	tt_move_forward.initialize(
		on_word_complete_forward_func,
		49, 
		26, 
		10,
		position,
		0.05
	)
	text_controller.unblock(tt_move_forward)
		
	# Preload up movement typing text
	var tt_move_up = preload("res://Scenes/TypingText.tscn").instantiate()
	# Calculate position so that the next typed letter is just after the half screen point
	var size2 = font.get_string_size("A".repeat(2 * 16), HORIZONTAL_ALIGNMENT_LEFT, -1, 39)
	add_child(tt_move_up)
	position = Vector2((get_viewport().size.x - size2.x) / 2, 840)
	# Function to be called by TypingText on word complete
	var on_word_complete_up_func = Callable(self, "_on_word_complete_up").bind(player)
	# Initalize
	tt_move_up.initialize(
		on_word_complete_up_func,
		39, 
		16, 
		4,
		position
	)
	text_controller.unblock(tt_move_up)
	
	# Preload down movement typing text
	var tt_move_down = preload("res://Scenes/TypingText.tscn").instantiate()
	add_child(tt_move_down)
	# Calculate position so that the next typed letter is just after the half screen point
	var size3 = font.get_string_size("A".repeat(2 * 16), HORIZONTAL_ALIGNMENT_LEFT, -1, 39)
	position = Vector2((get_viewport().size.x - size3.x) / 2, 925)
	# Function to be called by TypingText on word complete
	var on_word_complete_down_func = Callable(self, "_on_word_complete_down").bind(player)
	# Initalize
	tt_move_down.initialize(
		on_word_complete_down_func,
		39, 
		16, 
		4,
		position
	)
	text_controller.unblock(tt_move_down)

# Creates a typing text and attaches it (horizontally centered) to the given object
func create_attached_tt(
	on_word_complete_func: Callable, 
	object,
	font_size: int, 
	chars_per_side: int, 
	incoming_word_count: int, 
	y_offset: int,
	):
	return

func _ready():
	movement_tt_setup()

func _process(delta):
	return

######################################################
# These functions should be given to appropiate TypingText to call them
######################################################
func _on_word_complete_forward(completed_word, player):
	if completed_word.is_special:
		player.move(Vector2(2, 0))
	else:
		player.move(Vector2(1, 0))
	
func _on_word_complete_up(_completed_word, player):
	player.move(Vector2(0, -1))
	
func _on_word_complete_down(_completed_word, player):
	player.move(Vector2(0, 1))
