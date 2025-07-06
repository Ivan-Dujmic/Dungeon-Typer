extends Resource

var increase_amount = 16	# Flat increase

func execute(game: Game):
	game.player.action_range = game.player.action_range + increase_amount
