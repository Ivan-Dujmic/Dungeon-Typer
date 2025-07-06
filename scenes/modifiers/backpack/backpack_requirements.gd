extends Resource

func can_roll(game: Game) -> bool:
	return game.player.inventory.slots < game.player.inventory.max_rows * game.player.inventory.max_columns
