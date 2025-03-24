extends RichTextLabel

@onready var player = $"../../TilesViewportContainer/TilesViewport/Player"

var word_list: Array[String] = []
var word_list_size: int
var rng = RandomNumberGenerator.new()

var font_path = "res://Fonts/ia-writer-mono-latin-400-normal.ttf"
var space_sub = "⎵"	# Used to show a whitespace
var space_sub_unicode = space_sub.unicode_at(0)

var complete_color = "#08850a"	# Color for complete words
var partial_color = "#74e876"	# Color for complete characters of the current word
var wrong_color = "#ff3c00"	# Color for wrongly typed characters
var incoming_color = "#ffffff"	# Color for current and incoming characters

var typing_index = 24	# Position of character that is typed in zero-based indexing
var next_words: Array[String] = []
var chars_of_word_complete = 0	# How many characters of the current word are already typed
var chars_wrong = 0	# How many characters of the current word are wrongly typed
var last_removed_chars = ""	# Remember chars that were just removed from completed characters so we can return them if needed

func generate_random_word() -> String:
	return word_list[rng.randi_range(0, word_list_size-1)]
	#return("123456789")
	
func append_random_word():
	var random_word = generate_random_word() + space_sub
	text = text.insert(len(text) - 8, random_word)
	next_words.append(random_word)

func init_text():
	# Adds the colors tags and empty text at start
	# [color="COLOR_HEX"]text[/color]
	text += ("[color=" + complete_color + "]")
	text += (" ".repeat(typing_index))
	text += ("[/color]")
	
	text += ("[color=" + partial_color + "]")
	text += ("[/color]")
	
	text += ("[color=" + wrong_color + "]")
	text += ("[/color]")
	
	text += ("[color=" + incoming_color + "]")
	text += ("[/color]")
	
	for i in range(12):
		append_random_word()

func _ready():
	print("TypingText ready")
	
	position = Vector2(198, 850)
	set_size(Vector2(1524, size.y * 2))
	
	var font_family = load(font_path)
	add_theme_font_override("normal_font", font_family)
	add_theme_font_size_override("normal_font_size", 49)
	autowrap_mode = TextServer.AUTOWRAP_OFF
	
	var word_list_script = load("res://Data/WordList.gd")
	word_list = word_list_script.word_list
	word_list_size = word_list.size()
	
	init_text()
		
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		var key = event.unicode
		var next_char = get_parsed_text().substr(typing_index, 1)
		var next_char_unicode = next_char.unicode_at(0)
		if (next_char_unicode == key) or (key == " ".unicode_at(0) and next_char_unicode == space_sub_unicode):	# If correct input
			chars_of_word_complete += 1
			# Text manipulation
			# Size of bbcode color open is 15
			# Size of bbcode color closed is 8
			text = text.erase(84 + typing_index)	# Remove completed char from incoming characters
			text = text.insert(38 + typing_index, next_char)	# Put completed char in partially completed characters
			last_removed_chars += text.substr(15, 1)	# Remember the leftmost character
			text = text.erase(15)	# Remove leftmost character
			if key == 32:	# Space, complete word
				text = text.insert(15 + typing_index - chars_of_word_complete, next_words[0])	# Put completed word in completed part
				text = text.erase(38 + typing_index, chars_of_word_complete)	# Remove completed word from partially complete part
				next_words.remove_at(0)
				last_removed_chars = ""	# Because we can't return to finished correct words
				chars_of_word_complete = 0
				append_random_word()
				player.move(Vector2(16, 0))
		else:
			return
