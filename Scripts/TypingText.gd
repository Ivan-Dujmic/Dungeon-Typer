extends RichTextLabel
class_name TypingText

# "Constructor" variables
var on_word_complete: Callable	# Function to be called when a word is complete
var font_size
var chars_per_side	# Max chars on incoming side and completed part individually
var incoming_word_count

# Holds the text controller to which self should subscribe
var text_controller

# Format
var font_path = "res://Fonts/ia-writer-mono-latin-400-normal.ttf"
var font_family: Font
var space_sub = "⎵"	# Used to show a whitespace
var space_sub_unicode = space_sub.unicode_at(0)
var colors = {
	"complete": "#08850a",	# Color for complete words
	"wrong": "#ff3c00",		# Color for mistypes
	"incoming": "#ffffff",	# Color for current and incoming characters
	"special": "#ffdd80",	# Color for current and incoming special characters
}

# Word tracking
var incoming_words: Array = []	# Keeps the incoming words and their properties (special...)
var incorrect_mode = false	# Was the previous char mistyped?
var left_chars = ""	# Remember complete chars of current word and/or an incorrect char so we can undo

# Word modifiers
var rng = RandomNumberGenerator.new()
var special_word_chance = 0.05	# 1 = 100%

# Positional variables (because of tags)
var pos_first_left	# First character on left side
var pos_last_correct	# Last character on left side when incorrect_mode = false
var pos_wrong	# Last character on left side when incorrect_mode = true
var pos_first_raw_right	# Opening color tag of first right side (incoming) word
var pos_first_right	# Next incoming char

var color_tags_size = "[color=\"#000000\"][/color]".length()

func get_string_in_tags(string: String, color: String) -> String:
	var result = "[color=\"" + colors[color] + "\"]" + string + "[/color]"
	return result

func append_random_word():
	var random_word = text_controller.generate_word() + space_sub

	var is_special = false
	var color = "incoming"
	if rng.randf() <= special_word_chance:
		is_special = true
		color = "special"

	text += get_string_in_tags(random_word, color)
	incoming_words.append({ "word": random_word, "is_special": is_special })

func reset():
	for _c in range(left_chars.length()):
		text = text.insert(pos_first_right, left_chars[-1])	# Return the last complete/wrong char to incoming
		left_chars = left_chars.substr(0, left_chars.length() - 1)
		if incorrect_mode:
			text = text.erase(pos_wrong - 1)
			incorrect_mode = false
		else:
			text = text.erase(pos_last_correct - 1)
		text = text.insert(pos_first_left, " ")

func initialize(on_word_complete_init: Callable, font_size_init: int, chars_per_side_init: int, incoming_word_count_init: int, position_init: Vector2):
	on_word_complete = on_word_complete_init
	font_size = font_size_init
	chars_per_side = chars_per_side_init
	incoming_word_count = incoming_word_count_init
	position = position_init
	
	# Font and wrap settings
	font_family = load(font_path)
	add_theme_font_override("normal_font", font_family)
	add_theme_font_size_override("normal_font_size", font_size)
	autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# Position and size
	var elem_size = font_family.get_string_size("A".repeat(2 * chars_per_side), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	set_size(Vector2(elem_size.x, elem_size.y * 2))
	
	# Positional variables
	pos_first_left = "[color=\"#000000\"]".length()
	pos_last_correct = "[color=\"#000000\"]".length() + chars_per_side
	pos_wrong = "[color=\"#000000\"][/color][color=\"#000000\"]".length() + chars_per_side
	pos_first_raw_right = "[color=\"#000000\"][/color]".length() * 2 + chars_per_side
	pos_first_right = "[color=\"#000000\"][/color][color=\"#000000\"][/color][color=\"#000000\"]".length() + chars_per_side
	
	# Word initialization
	# The left (complete) side always has a fixed number of raw characters = 2 * color_tags_size + chars_per_size
	# The right side has each word in it's own tags
	text = get_string_in_tags(" ".repeat(chars_per_side), "complete") + get_string_in_tags("", "wrong")
	for i in range(incoming_word_count):
		append_random_word()

func _ready():
	text_controller = get_node("/root/Game/TextController")
	text_controller.attach(self)
	
func process_input(event):
	var next_char = text.substr(pos_first_right, 1)
	var next_char_unicode = next_char.unicode_at(0)
	if not incorrect_mode and event.unicode != 0 and ((next_char_unicode == event.unicode) or (event.unicode == " ".unicode_at(0) and next_char_unicode == space_sub_unicode)):	# If correct input		left_chars += next_char
		left_chars += next_char
		text = text.erase(pos_first_right)	# Remove completed char from incoming characters
		text = text.insert(pos_last_correct, next_char)	# Put complete char on left side
		text = text.erase(pos_first_left)	# Remove leftmost character
		if event.unicode == 32:	# Space, complete word
			text = text.erase(pos_first_left, chars_per_side)	# Erase completed word
			text = text.insert(pos_first_left, " ".repeat(chars_per_side))
			text = text.erase(pos_first_raw_right, color_tags_size)	# Remove the color tags of the complete incoming word on right
			var completed_word = incoming_words.pop_at(0)	# Remove completed incoming word
			left_chars = ""	# Because we can't return to finished correct words
			append_random_word()
			on_word_complete.call(completed_word)
			return { "type": text_controller.InputResult.FINISHED, "word": completed_word["word"] }
		return { "type": text_controller.InputResult.CORRECT }
	elif event.keycode == KEY_BACKSPACE:	# Backspace
		if left_chars.length() != 0:
			text = text.insert(pos_first_right, left_chars[-1])	# Return the last complete/wrong char to incoming
			left_chars = left_chars.substr(0, left_chars.length() - 1)
			if incorrect_mode:
				text = text.erase(pos_wrong - 1)
				incorrect_mode = false
			else:
				text = text.erase(pos_last_correct - 1)
			text = text.insert(pos_first_left, " ")
		if left_chars.length() == 0:	# If last char was just removed
			return { "type": text_controller.InputResult.DELETED }
		return { "type": text_controller.InputResult.CORRECT }
	# TODO: CTRL + Backspace
	elif event.unicode == 0:	# Modfier keys shouldn't cause a mistake
		return { "type": text_controller.InputResult.CORRECT }
	else:	# Wrong input
		if not incorrect_mode:
			incorrect_mode = true
			left_chars += next_char
			text = text.erase(pos_first_right)	# Remove wrong char from incoming characters
			text = text.insert(pos_wrong, next_char)	# Put wrong char on left side
			text = text.erase(pos_first_left)	# Remove leftmost character
			return { "type": text_controller.InputResult.INCORRECT }
		else:
			return { "type": text_controller.InputResult.CORRECT }
