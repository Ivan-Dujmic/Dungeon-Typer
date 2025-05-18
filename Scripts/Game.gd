extends Node2D

@onready var tiles_viewport_container = $TilesViewportContainer
@onready var tiles_viewport = $TilesViewportContainer/TilesViewport
@onready var player = $TilesViewportContainer/TilesViewport/YSort/Player
@onready var enemy_generator = $TilesViewportContainer/TilesViewport/YSort/EnemyGenerator
@onready var dungeon_generator = $TilesViewportContainer/TilesViewport/YSort/DungeonGenerator

var difficulty = 10

func _ready():
	var viewport = get_viewport_rect()
	var ratio = viewport.size.x / tiles_viewport.size.x
	tiles_viewport_container.scale = Vector2(ratio, ratio)
	
	player.initialize_stats(difficulty)
	enemy_generator.difficulty = difficulty
	dungeon_generator.difficulty = difficulty
