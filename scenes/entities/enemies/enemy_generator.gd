extends Node2D

@onready var player = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player")

@onready var skeleton_scene = preload("res://scenes/entities/enemies/skeleton/skeleton.tscn")
@onready var skeleton_class = preload("res://scenes/entities/enemies/skeleton/skeleton_class.tres")

var rng = RandomNumberGenerator.new()

var difficulty

# The position should be a tile coordinate
func attempt_enemy_spawn(enemy: String, chance: float, position_init: Vector2i):
	if rng.randf() <= chance:
		match enemy:
			"Skeleton":
				var new_enemy = skeleton_scene.instantiate()
				add_child(new_enemy)
				new_enemy.initialize(skeleton_class, difficulty, position_init)
				new_enemy.set_target(player)
			_:
				return
	return

func _ready():
	return
