extends Resource

func execute(game: Game):
	game.player.inventory.resize(game.player.inventory.slots + 1)
