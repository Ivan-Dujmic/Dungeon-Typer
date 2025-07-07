extends Node2D

@onready var player = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player")

@onready var skeleton_scene = preload("res://scenes/entities/enemies/skeleton/skeleton.tscn")
@onready var skeleton_class = preload("res://scenes/entities/enemies/skeleton/skeleton_class.tres")
@onready var flaming_skull_scene = preload("res://scenes/entities/enemies/flaming_skull/flaming_skull.tscn")
@onready var flaming_skull_class = preload("res://scenes/entities/enemies/flaming_skull/flaming_skull_class.tres")
@onready var lich_scene = preload("res://scenes/entities/bosses/lich/lich.tscn")
@onready var lich_class = preload("res://scenes/entities/bosses/lich/lich_class.tres")

var rng = RandomNumberGenerator.new()

# The position should be a tile coordinate
func attempt_enemy_spawn(enemy: String, chance: float, position_init: Vector2i):
	if rng.randf() <= chance:
		match enemy:
			"Skeleton":
				var new_enemy = skeleton_scene.instantiate()
				add_child(new_enemy)
				new_enemy.initialize(skeleton_class, position_init)
				new_enemy.set_target(player)
			"Flaming Skull":
				var new_enemy = flaming_skull_scene.instantiate()
				add_child(new_enemy)
				new_enemy.initialize(flaming_skull_class, position_init)
				new_enemy.set_target(player)
			"Lich":
				var new_enemy = lich_scene.instantiate()
				add_child(new_enemy)
				new_enemy.initialize(lich_class, position_init)
				new_enemy.set_target(player)
				GameState.boss_active = true
			_:
				return
	return

func _ready():
	return
