extends Resource

var heal_amount = 0.15	# 1 = 100%

func execute(player: Player):
	player.heal(player.max_health * heal_amount)
