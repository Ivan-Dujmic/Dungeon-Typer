extends Resource

func can_roll(game: Game) -> bool:
	return game.player.health_regen > 0
