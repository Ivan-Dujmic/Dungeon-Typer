extends Resource

func can_roll(game: Game) -> bool:
	return game.player.luck > 0
