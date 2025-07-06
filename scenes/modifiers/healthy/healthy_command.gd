extends Resource

var increase_amount = 0.25	# Percentage of current stat

func execute(game: Game):
	game.player.max_health += game.player.max_health * increase_amount
