extends CanvasLayer

func _ready():
	# Preload forward movement typing text
	var tt = preload("res://Scenes/TypingText.tscn").instantiate()
	add_child(tt)
	var player = get_node("/root/Game/TilesViewportContainer/TilesViewport/Player")
	# Calculate position so that the next typed letter is just after the half screen point
	var font = load("res://Fonts/ia-writer-mono-latin-400-normal.ttf")
	var size = font.get_string_size("A".repeat(2 * 26), HORIZONTAL_ALIGNMENT_LEFT, -1, 42)
	var position = Vector2((get_viewport().size.x - size.x) / 2, 850)
	# Function to be called by TypingText on word complete
	var on_word_complete_forward_func = Callable(self, "_on_word_complete_forward").bind(player)
	# Initalize
	tt.initialize(
		on_word_complete_forward_func,
		49, 
		26, 
		12,
		position
	)
		
	# Preload up movement typing text
	var tt2 = preload("res://Scenes/TypingText.tscn").instantiate()
	add_child(tt2)
	position = Vector2((get_viewport().size.x - size.x) / 2, 800)
	# Function to be called by TypingText on word complete
	var on_word_complete_up_func = Callable(self, "_on_word_complete_up").bind(player)
	# Initalize
	tt2.initialize(
		on_word_complete_up_func,
		49, 
		26, 
		12,
		position
	)
	
	# Preload down movement typing text
	var tt3 = preload("res://Scenes/TypingText.tscn").instantiate()
	add_child(tt3)
	position = Vector2((get_viewport().size.x - size.x) / 2, 900)
	# Function to be called by TypingText on word complete
	var on_word_complete_down_func = Callable(self, "_on_word_complete_down").bind(player)
	# Initalize
	tt3.initialize(
		on_word_complete_down_func,
		49, 
		26, 
		12,
		position
	)

func _on_word_complete_forward(_completed_word, player):
	player.move(Vector2(16, 0))
	
func _on_word_complete_up(_completed_word, player):
	player.move(Vector2(0, -16))
	
func _on_word_complete_down(_completed_word, player):
	player.move(Vector2(0, 16))
