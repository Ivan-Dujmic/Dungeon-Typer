extends Resource

func can_roll(game: Game) -> bool:
	return game.player.action_range < game.player.max_action_range
