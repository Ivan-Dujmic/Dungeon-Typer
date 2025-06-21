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
var texts: Array[MenuText]
var active_texts: Array[MenuText]
var blocked_texts: Array[MenuText]

# Used because completing a word that changes screen also unblocks all other texts
# which would continue iterating through the active_texts array which gets changed
# and they usually all get blocked
var activate_was_called = false

func attach(tt: MenuText):
	texts.push_back(tt)
	
func detach(tt: MenuText):
	texts.erase(tt)
	active_texts.erase(tt)
	blocked_texts.erase(tt)
	
func activate_texts(new_active: Array):	# Array of MenuText (can't state because of no nested typing support)
	# Block
	for tt in texts:
		tt.reset()
		blocked_texts.push_back(tt)
	texts.clear()
	active_texts.clear()
	
	# Unblock
	for tt in new_active:
		blocked_texts.erase(tt)
		texts.push_back(tt)
		active_texts.push_back(tt)
		
	state = 1
	activate_was_called = true
	
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		var incorrect_texts: Array[MenuText] = []
		var iteration = 0	# Activate was called will block first input when it shouldn't if the screen change was called from non text source
		for text in active_texts:
			if activate_was_called:
				activate_was_called = false
				if iteration > 0:
					return
			iteration += 1
			var result = text.process_input(event)
			match result:
				InputResult.CORRECT:
					state = 1	# We have now started at least 1 word
				InputResult.INCORRECT:
					incorrect_texts.push_back(text)	# We still don't know if it should be red or reset
				InputResult.FINISHED:	# Word finished, reset
					state = 0
				InputResult.DELETED:	# Word(s) undoed, reset
					state = 0
		if state == 0:	# In cases of reset, finish, or when input doesn't fit any text
			active_texts = texts.duplicate()
		elif state == 1:	# If there's any active texts left, then non-matching ones should be reset
			if active_texts.size() - incorrect_texts.size() > 0:
				for text in incorrect_texts:
					active_texts.erase(text)
					text.reset()
