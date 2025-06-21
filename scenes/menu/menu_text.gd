extends RichTextLabel
class_name MenuText

# "Constructor" variables
var raw_text: String
var on_word_complete: Callable	# Function to be called when a word is complete
var font_size

# Holds the text controller to which self should subscribe
var text_controller

# Format
var font_path = "res://assets/fonts/ia-writer-mono-latin-700-normal.ttf"
var font_family: Font
var colors = {
	"complete": "#ffffff",	# Color for complete words
	"wrong": "#ff0000",		# Color for mistypes
	"incoming": "#de6600",	# Color for current and incoming characters
}

# Word tracking
var chars_completed
var incorrect_mode = false	# Was the previous char mistyped?
var pos_last_correct
var pos_incorrect
var pos_first_incoming

var color_tags_size = "[color=\"#000000\"][/color]".length()

func get_string_in_tags(string: String, color: String) -> String:
	var result = "[color=\"" + colors[color] + "\"]" + string + "[/color]"
	return result

func reset():
	text = " " + get_string_in_tags("", "complete") + get_string_in_tags("", "wrong") + get_string_in_tags(raw_text, "incoming")
	chars_completed = 0
	incorrect_mode = false
	
	# Positional variables
	pos_last_correct = "[color=\"#000000\"]".length()
	pos_incorrect = "[color=\"#000000\"][/color][color=\"#000000\"]".length() + 1
	pos_first_incoming = "[color=\"#000000\"][/color][color=\"#000000\"][/color][color=\"#000000\"]".length() + 1

func initialize(text_controller_init, text_init: String, on_word_complete_init: Callable, font_size_init: int, position_init: Vector2):
	text_controller = text_controller_init
	raw_text = text_init + " "
	on_word_complete = on_word_complete_init
	font_size = font_size_init
	position = position_init
	
	text_controller.attach(self)
	
	# Font and wrap settings
	font_family = load(font_path)
	add_theme_font_override("normal_font", font_family)
	add_theme_font_size_override("normal_font_size", font_size)
	autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# Position and size
	var elem_size = font_family.get_string_size(" " + raw_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	set_size(elem_size)
	var parent_size = get_parent().size
	var offset = (parent_size - elem_size) / 2
	offset_left = offset.x
	offset_top = offset.y
	anchor_left = 0
	anchor_top = 0
	anchor_right = 1
	anchor_bottom = 1
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	# Word initialization & positional variables
	reset()

func _ready():
	return
	
func process_input(event):
	var next_char = text.substr(pos_first_incoming, 1)
	var next_char_lower_unicode = next_char.to_lower().unicode_at(0)
	if not incorrect_mode and event.unicode != 0 and String.chr(next_char_lower_unicode) == String.chr(event.unicode).to_lower():	# If correct input
		chars_completed += 1
		text = text.erase(pos_first_incoming)	# Remove completed char from incoming characters
		text = text.insert(pos_last_correct + 1, next_char)	# Put complete char on left side
		pos_last_correct += 1
		pos_incorrect += 1
		pos_first_incoming += 1
		if event.unicode == 32:	# Space, complete word
			reset()
			on_word_complete.call()
			return text_controller.InputResult.FINISHED
		return text_controller.InputResult.CORRECT
	elif event.keycode == KEY_BACKSPACE:	# Backspace
		if event.ctrl_pressed:	# CTRL + Backspace
			reset()
			return text_controller.InputResult.DELETED
		else:	# Just Backspace
			if chars_completed != 0 || incorrect_mode:
				if incorrect_mode:
					text = text.insert(pos_first_incoming, text.substr(pos_incorrect, 1))
					text = text.erase(pos_incorrect)
					incorrect_mode = false
					pos_first_incoming -= 1
				else:
					text = text.insert(pos_first_incoming, text.substr(pos_last_correct, 1))
					text = text.erase(pos_last_correct)
					pos_last_correct -= 1
					pos_incorrect -= 1
					pos_first_incoming -= 1
					chars_completed -= 1
			if chars_completed == 0:	# If last char was just removed
				return text_controller.InputResult.DELETED
			return text_controller.InputResult.CORRECT
	elif event.unicode == 0:	# Modfier keys shouldn't cause a mistake
		return text_controller.InputResult.CORRECT
	else:	# Wrong input
		if not incorrect_mode:
			incorrect_mode = true
			text = text.erase(pos_first_incoming)
			text = text.insert(pos_incorrect, next_char)
			pos_first_incoming += 1
			return text_controller.InputResult.INCORRECT
		else:
			return text_controller.InputResult.CORRECT
