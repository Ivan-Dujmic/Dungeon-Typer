extends Resource

var heal_amount = 0.1	# 1 = 100%

func execute(player: Player):
	player.heal(player.health * heal_amount)
