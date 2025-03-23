extends RichTextLabel

var word_list: Array[String] = []
var word_list_size: int
var rng = RandomNumberGenerator.new()

func generate_random_word() -> String:
	return word_list[rng.randi_range(0, word_list_size)]

func _ready():
	position = Vector2(35, 130)
	set_size(Vector2(250, size.y))
	
	var font_times = load("res://Fonts/times.ttf")
	add_theme_font_override("normal_font", font_times)
	add_theme_font_size_override("normal_font_size", 10)
	
	var word_list_script = load("res://Data/WordList.gd")
	word_list = word_list_script.word_list
	word_list_size = word_list.size()
	
	for i in range(10):
		#append_text(generate_random_word())
		pass
