extends CanvasLayer

@onready var game = get_node("/root/Game")
@onready var text_controller = get_node("/root/Game/TextController")
@onready var player = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player")
@onready var camera = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player/Camera")

@onready var typing_text_scene = preload("res://scenes/ui/typing/typing_text.tscn")

var font = load("res://assets/fonts/ia-writer-mono-latin-400-normal.ttf")

# attached_tt_dict[tt] = [object, size, y_offset]
var attached_tt_dict: Dictionary

func movement_tt_setup():
	# Preload forward movement typing text
	var tt_move_forward = typing_text_scene.instantiate()
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
	var tt_move_up = typing_text_scene.instantiate()
	# Calculate position so that the next typed letter is just after the half screen point
	size = font.get_string_size("A".repeat(2 * 16), HORIZONTAL_ALIGNMENT_LEFT, -1, 39)
	add_child(tt_move_up)
	position = Vector2((get_viewport().size.x - size.x) / 2, 840)
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
	var tt_move_down = typing_text_scene.instantiate()
	add_child(tt_move_down)
	# Calculate position so that the next typed letter is just after the half screen point
	size = font.get_string_size("A".repeat(2 * 16), HORIZONTAL_ALIGNMENT_LEFT, -1, 39)
	position = Vector2((get_viewport().size.x - size.x) / 2, 925)
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
	on_word_complete_func: Callable,	# With .bind()
	object,
	font_size: int, 
	chars_per_side: int, 
	incoming_word_count: int, 
	y_offset: int,
	unblock: bool
	) -> TypingText:
	var tt = typing_text_scene.instantiate()
	add_child(tt)
	var position = Vector2.ZERO	# Process will do it anyways
	tt.initialize(
		on_word_complete_func,
		font_size,
		chars_per_side,
		incoming_word_count,
		position
	)
	
	if unblock:
		text_controller.unblock(tt)
		
	var size = font.get_string_size("A".repeat(2 * chars_per_side), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	attached_tt_dict[tt] = [object, size, y_offset]
	return tt

func create_enemy_tt(enemy: Enemy) -> TypingText:
	var on_word_complete_attack_func = Callable(self, "_on_word_complete_attack").bind(player, enemy)
	return create_attached_tt(on_word_complete_attack_func, enemy, 24, 14, 2, -13, false)

func create_item_drop_tt(item_drop: ItemDrop) -> TypingText:
	var on_word_complete_pick_up_func = Callable(self, "_on_word_complete_pick_up").bind(player, item_drop)
	return create_attached_tt(on_word_complete_pick_up_func, item_drop, 24, 14, 1, -8, false)

func _ready():
	movement_tt_setup()

func _process(_delta):
	var tt_to_remove: Array[TypingText]	# We don't want to erase from dict while iterating through it
	var ratio = game.ratio
	for tt in attached_tt_dict:
		var data = attached_tt_dict[tt]
		if is_instance_valid(data[0]):
			# Data = [object, size, y_offset]
			var position = data[0].global_position - camera.global_position	# Object middle - camera middle
			position.y += data[2]	# y_offset
			position *= ratio	# Scale for viewport
			position.x -= data[1].x / 2	# - Half of text width
			position.y -= data[1].y	# - Text height
			position += Vector2(get_viewport().size) / 2	# Camera is centered, viewport is top left
			tt.position = position
		else:
			tt_to_remove.push_back(tt)
		
	for tt in tt_to_remove:
		attached_tt_dict.erase(tt)
		text_controller.detach(tt)
		tt.queue_free()

######################################################
# These functions should be given to appropiate TypingText to call them
######################################################
func _on_word_complete_forward(completed_word, player_arg: Player):
	if completed_word.is_special:
		player_arg.move(Vector2(2, 0))
	else:
		player_arg.move(Vector2(1, 0))
	
func _on_word_complete_up(_completed_word, player_arg: Player):
	player_arg.move(Vector2(0, -1))
	
func _on_word_complete_down(_completed_word, player_arg: Player):
	player_arg.move(Vector2(0, 1))
	
func _on_word_complete_attack(completed_word, player_arg: Player, enemy: Enemy):
	var damage = player_arg.attack * 2 if completed_word.is_special else player_arg.attack
	enemy.take_damage(damage)
	
func _on_word_complete_pick_up(_completed_word, player_arg: Player, item_drop: ItemDrop):
	if item_drop.data.use_on_pickup:
		item_drop.data.use_command.new().execute(player_arg)
		item_drop.queue_free()
	else:
		pass # TODO: Add to inventory
