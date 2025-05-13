extends Node

enum InputResult {
	INCORRECT,	# Incorrect input
	CORRECT,	# Correct input
	FINISHED,	# Correct input and the word is finished, comes along with String word
	DELETED		# Correct input (backspace) that just deleted the final character of the word
}

# State 0 is active during free selection when any text can become active on character typed
# State 1 is active after a text(s) has been chosen as active.
var state = 0
var texts: Array[TypingText]
var active_texts: Array[TypingText]
var present_words: Array[String]
var word_list = load("res://Data/WordList.gd").word_list
var word_list_size = word_list.size()
var rng = RandomNumberGenerator.new()

func attach(tt: TypingText):
	texts.push_back(tt)
	if state == 0:
		active_texts.push_back(tt)
	
func detach(tt: TypingText):
	texts.erase(tt)
	active_texts.erase(tt)
	
func generate_word() -> String:
	while(true):
		var new_word = word_list[rng.randi_range(0, word_list_size-1)]
		var is_subsumed = false
		for word in present_words:
			if word.begins_with(new_word) or new_word.begins_with(word):
				is_subsumed = true
				break
		if not is_subsumed:
			present_words.push_back(new_word)
			return new_word
	return ""
	
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		var incorrect_texts: Array[TypingText] = []
		for text in active_texts:
			var result = text.process_input(event)
			match result.type:
				InputResult.CORRECT:
					state = 1	# We have now started at least 1 word
				InputResult.INCORRECT:
					incorrect_texts.push_back(text)	# We still don't know if it should be red or reset
				InputResult.FINISHED:	# Word finished, reset
					present_words.erase(result.word)
					state = 0
				InputResult.DELETED:	# Word(s) undoed, reset
					state = 0
		if state == 0:	# In cases of reset, finish or when input doesn't fit any text
			active_texts = texts.duplicate()
		elif state == 1:	# If there's an active texts, then non-matching ones should be reset
			if active_texts.size() - incorrect_texts.size() > 0:
				for text in incorrect_texts:
					active_texts.erase(text)
					text.reset()
