extends Node

# Indexes for option buttons, strings for their text
const WINDOW_MODES: Array[String] = [
	"Fullscreen",
	"Windowed",
	"Borderless Windowed"
]

const RESOLUTIONS: Array[Array] = [
	["3840 x 2160", Vector2i(3840, 2160)],
	["2560 x 1440", Vector2i(2560, 1440)],
	["1920 x 1080", Vector2i(1920, 1080)],
	["1440 x 900", Vector2i(1440, 900)],
	["1280 x 720", Vector2i(1280, 720)]
]

var window_mode: int = 0
var resolution: int = 2
var screen: int = 1

# Check WINDOW_MODES const
func set_window_mode(mode: int = -1):
	if mode != -1:
		window_mode = mode
		
	match window_mode:
		0:	# Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:	# Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:	# Windowed Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	set_resolution()

# Check RESOLUTIONS const
func set_resolution(res: int = -1):
	if res != -1:
		resolution = res
		
	DisplayServer.window_set_size(RESOLUTIONS[resolution][1])
	center_window()
	
	Save.save_game()

func set_screen(index: int = -1):
	if index != -1:
		screen = index
	else:
		index = screen
		
	var screen_count = DisplayServer.get_screen_count()
	if index > screen_count - 1:
		index = 0
		
	DisplayServer.window_set_current_screen(index)
	center_window()
	
	Save.save_game()

func center_window():
	var screen_index = DisplayServer.window_get_current_screen()
	var screen_size = DisplayServer.screen_get_size(screen_index)
	var screen_pos = DisplayServer.screen_get_position(screen_index)
	var window_size = DisplayServer.window_get_size()
	var center_pos = screen_pos + (screen_size - window_size) / 2
	DisplayServer.window_set_position(center_pos)

func apply_all_settings():
	set_window_mode()
	set_resolution()
	set_screen()
