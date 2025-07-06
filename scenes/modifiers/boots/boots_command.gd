extends Resource

var increase_amount = 0.1	# Percentage of current stat

func execute(game: Game):
	game.player.speed += game.player.speed * increase_amount
