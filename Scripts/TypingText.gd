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

var next_words: Array[String] = []
var chars_of_word_complete = 0

func generate_random_word() -> String:
	return word_list[rng.randi_range(0, word_list_size-1)]
	#return("123456789")
	
func append_random_word():
	var random_word = generate_random_word() + space_sub
	text += random_word
	next_words.append(random_word)

func init_text():
	# Adds the colors tags and empty text at start
	text += ("[color=" + complete_color + "]")
	text += (" ".repeat(24))
	text += ("[/color]")
	for color in [partial_color]:
		# [color="COLOR_HEX"][/color]
		text += ("[color=" + color + "]" + "[/color]")

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
	for i in range(12):
		append_random_word()
		
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		var key = event.unicode
		var next_char = get_parsed_text().substr(24, 1)
		var next_char_unicode = next_char.unicode_at(0)	# 24 because we're writing at the middle of the text
		if (next_char_unicode == key) or (key == " ".unicode_at(0) and next_char_unicode == space_sub_unicode):	# If correct input
			chars_of_word_complete += 1
			text = text.erase(70)	# Remove completed char from incoming characters
			text = text.insert(62, next_char)	# Put completed char in partially completed characters
			text = text.erase(15)	# Remove leftmost character
			if key == 32:	# Space, next word
				print(text)
				text = text.insert(39 - chars_of_word_complete, next_words[0])	# Put completed word in completed part
				print(text)
				text = text.erase(62, chars_of_word_complete)
				print(text)
				next_words.remove_at(0)
				chars_of_word_complete = 0
				append_random_word()
				player.move(Vector2(16, 0))
