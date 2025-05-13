extends Node

var rng = RandomNumberGenerator.new()

# The position should be a tile coordinate
func attempt_enemy_spawn(enemy: String, chance: float, position_init: Vector2i):
	if rng.randf() <= chance:
		match enemy:
			"Skeleton":
				var new_enemy = preload("res://Scenes/Skeleton.tscn").instantiate()
				add_child(new_enemy)
				new_enemy.initialize(position_init)
			_:
				return
	return

func _ready():
	return
