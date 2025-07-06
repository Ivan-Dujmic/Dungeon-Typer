extends Node

const TILE_SIZE: int = 16

const dungeons: Array[String] = [
	"Crypts",
	"Forest",
]

const characters: Array[String] = [
	"Knight",
	"Wizard",
	"Vampire",
	"Tank",
]

const modifiers: Array[String] = [
	"Strength",
	"Backpack",
	"Regeneration",
	"Healthy",
	"Lucky",
	"Eyesight",
	"Boots",
]

func roll_modifiers(game: Game, amount: int) -> Array[ModifierData]:
	var available: Array[ModifierData] = []
	for modifier in modifiers:
		var folder = modifier.to_lower().replace(" ", "_")
		var mod = load("res://scenes/modifiers/%s/%s.tres" % [folder, folder])
		if mod.requirements.new().can_roll(game):
			available.push_back(mod)
	available.shuffle()
	return available.slice(0, amount)
		
