extends Control

@onready var player = $"../../TilesViewportContainer/TilesViewport/Player"
@onready var left_text = $Left
@onready var right_text = $Right

var word_list: Array[String] = []
var word_list_size: int
var rng = RandomNumberGenerator.new()

var font_path = "res://Fonts/ia-writer-mono-latin-400-normal.ttf"
var font_family: Font
var space_sub = "⎵"	# Used to show a whitespace
var space_sub_unicode = space_sub.unicode_at(0)

var colors = {
	"complete": "#08850a",	# Color for complete words
	"partial": "#74e876",	# Color for complete characters of the current word
	"wrong": "#ff3c00",		# Color for mistypes
	"incoming": "#ffffff",	# Color for current and incoming characters
	"special": "#ffdd80",	# Color for current and incoming special characters
}

var color_tags_size = "[color=\"#000000\"][/color]".length()

var font_size = 49
var chars_per_side = 26
var incoming_word_count = 12

var next_words: Array[String] = []
var chars_of_word_complete = 0	# How many characters of the current word are already typed
var chars_wrong = 0	# How many characters of the current word are wrongly typed
var last_removed_chars = ""	# Remember chars that were just removed from completed characters so we can return them if needed

enum MistypeModes { MULTIPLE_MISS, ONE_MISS, SKIP_MISS }
# MULTIPLE_MISS -> Can keep missing until no more text left, but has to fix before moving
# ONE_MISS -> Any miss after the first miss will stay at the first miss, but has to fix before moving
# SKIP_MISS -> Can go to next word without fixing, but that word won't count to moving
var mistype_mode = MistypeModes.MULTIPLE_MISS
var can_move_on_mistype = false	# Tells us if next finished word will move after getting a mistype

var special_word_chance = 0.0	# 1 = 100%
var bold_word_chance = 0.0	# 1 = 100%

func get_string_in_tags(string: String, color: String, bold: bool) -> String:
	var result = ""
	result += "[color=\"" + colors[color] + "\"]"
	if bold:
		result += "[b]"
	result += string
	if bold:
		result += "[/b]"
	result += "[/color]"

	return result

func generate_random_word() -> String:
	return word_list[rng.randi_range(0, word_list_size-1)]

func append_random_word():
	var random_word = generate_random_word() + space_sub

	var color = "incoming"
	if rng.randf_range(0.0, 1.0) <= special_word_chance:
		color = "special"

	var bold = false
	if rng.randf_range(0.0, 1.0) <= bold_word_chance:
		bold = true

	right_text.text += get_string_in_tags(random_word, color, bold)
	next_words.append(random_word)
	
func init_text():
	for i in range(incoming_word_count):
		append_random_word()

	left_text.text += get_string_in_tags(" ".repeat(chars_per_side), "complete", false)

# Returns bbcode index of char in given RichTextLabel
# mode: 0->first_char ; 1->last_char
func get_char_index(side: RichTextLabel, mode: int) -> int:
	var depth = 0
	if mode == 0:
		for i in range(side.text.length()):
			if side.text[i] == "[":
				depth += 1
			elif side.text[i] == "]":
				depth -= 1
			elif depth == 0:
				return i

	if mode == 1:
		for i in range(side.text.length() - 1, -1, -1):
			if side.text[i] == "]":
				depth += 1
			elif side.text[i] == "[":
				depth -= 1
			elif depth == 0:
				return i

	return -1

func adjust_left_size():
	# Left part should end at the middle of the screen
	var text_size = font_family.get_string_size(left_text.get_parsed_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	left_text.position = Vector2((get_viewport().size.x / 2) - text_size.x, 850)
	left_text.set_size(Vector2(text_size.x, text_size.y * 2))

func _ready():
	# Font and wrap settings
	font_family = load(font_path)
	left_text.add_theme_font_override("normal_font", font_family)
	right_text.add_theme_font_override("normal_font", font_family)
	left_text.add_theme_font_size_override("normal_font_size", font_size)
	right_text.add_theme_font_size_override("normal_font_size", font_size)
	left_text.add_theme_font_size_override("bold_font_size", font_size)
	right_text.add_theme_font_size_override("bold_font_size", font_size)
	left_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	right_text.autowrap_mode = TextServer.AUTOWRAP_OFF

	var right_side_size = font_family.get_string_size("A".repeat(chars_per_side), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	right_text.position = Vector2(get_viewport().size.x / 2, 850)	# Right part starts at the middle of the screen
	right_text.set_size(Vector2(right_side_size.x, right_side_size.y * 2))

	# Load word list
	var word_list_script = load("res://Data/WordList.gd")
	word_list = word_list_script.word_list
	word_list_size = word_list.size()

	init_text()

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		var key = event.unicode
		var next_char = right_text.get_parsed_text().substr(0, 1)
		var next_char_unicode = next_char.unicode_at(0)
		if key != 0 and ((next_char_unicode == key) or (key == " ".unicode_at(0) and next_char_unicode == space_sub_unicode)):	# If correct input
			chars_of_word_complete += 1
			right_text.text = right_text.text.erase(get_char_index(right_text, 0))	# Remove completed char from incoming characters
			last_removed_chars += left_text.text[get_char_index(left_text, 0)]	# Remember the leftmost character
			left_text.text = left_text.text.erase(get_char_index(left_text, 0))	# Remove leftmost character
			left_text.text += get_string_in_tags(next_char, "partial", false)	# Put completed char in partially completed characters
			adjust_left_size()
			if key == 32:	# Space, complete word
				left_text.text = left_text.text.erase(left_text.text.length() - chars_of_word_complete * (color_tags_size + 1), chars_of_word_complete * (color_tags_size + 1))
				left_text.text += get_string_in_tags(next_words[0], "complete", false)
				#text = text.insert(15 + typing_index - chars_of_word_complete, next_words[0])	# Put completed word in completed part
				#text = text.erase(38 + typing_index, chars_of_word_complete)	# Remove completed word from partially complete part
				next_words.remove_at(0)
				last_removed_chars = ""	# Because we can't return to finished correct words
				chars_of_word_complete = 0
				append_random_word()
				player.move(Vector2(16, 0))
