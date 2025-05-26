extends Node2D

@onready var player = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player")

var rng = RandomNumberGenerator.new()

var difficulty

# The position should be a tile coordinate
func attempt_enemy_spawn(enemy: String, chance: float, position_init: Vector2i):
	if rng.randf() <= chance:
		match enemy:
			"Skeleton":
				var speed_init = rng.randf_range(difficulty * 1.5, difficulty * 3)
				var new_enemy = preload("res://scenes/entities/enemies/skeleton/skeleton.tscn").instantiate()
				add_child(new_enemy)
				new_enemy.initialize(position_init, speed_init)
				new_enemy.set_target(player)
			_:
				return
	return

func _ready():
	return
