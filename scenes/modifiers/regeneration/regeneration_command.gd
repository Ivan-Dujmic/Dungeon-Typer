extends Resource

var increase_amount = 0.25	# Percentage of current stat

func execute(game: Game):
	game.player.health_regen += 1 + game.player.health_regen * increase_amount
