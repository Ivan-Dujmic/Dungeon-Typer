extends Resource

var increase_amount = 0.2	# Percentage of current stat

func execute(game: Game):
	game.player.luck += game.player.luck * increase_amount
