extends Resource
class_name LootTable

@export var drops: Array[LootEntry]

func roll() -> Array[ItemData]:
	var drop_list: Array[ItemData] = []
	
	for drop in drops:
		if randf() <= drop.chance:
			drop_list.append(drop.item)
			
	return drop_list
