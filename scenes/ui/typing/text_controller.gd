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
var blocked_texts: Array[TypingText]
var present_words: Array[String]
var word_list = load("res://scenes/game/word_list.gd").word_list
var word_list_size = word_list.size()
var rng = RandomNumberGenerator.new()
var ignore = false	# When going from one text controller to another, we want to ignore one character

func attach(tt: TypingText):
	texts.push_back(tt)
	if state == 0:
		active_texts.push_back(tt)
	
func detach(tt: TypingText):
	texts.erase(tt)
	active_texts.erase(tt)
	blocked_texts.erase(tt)
	
func generate_word() -> String:
	while(true):
		var exists = false
		var new_word = word_list[rng.randi_range(0, word_list_size-1)]
		for word in present_words:
			if word == new_word:
				exists = true
				break
		if not exists:
			present_words.append(new_word)
			return new_word
	return ""
	
func block(tt: TypingText):
	active_texts.erase(tt)
	texts.erase(tt)
	blocked_texts.push_back(tt)
	tt.block()
	if state == 1 and active_texts.size() == 0:	# If that was the only active text then make all non-blocked active
		state = 0
		active_texts = texts.duplicate()
	
func unblock(tt: TypingText):
	blocked_texts.erase(tt)
	texts.push_back(tt)
	if state == 0:
		active_texts.push_back(tt)
	tt.unblock()
	
func _unhandled_input(event: InputEvent):
	if ignore:
		ignore = false
		return
		
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
					GameState.run_words_completed += 1
					GameState.run_characters_typed += len(result.word)
				InputResult.DELETED:	# Word(s) undoed, reset
					state = 0
		if state == 0:	# In cases of reset, finish or when input doesn't fit any text
			active_texts = texts.duplicate()
		elif state == 1:	# If there's any active texts left, then non-matching ones should be reset
			if active_texts.size() - incorrect_texts.size() > 0:
				for text in incorrect_texts:
					active_texts.erase(text)
					text.reset()
