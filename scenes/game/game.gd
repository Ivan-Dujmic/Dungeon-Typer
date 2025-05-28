extends Node2D

@onready var tiles_viewport_container = $TilesViewportContainer
@onready var tiles_viewport = $TilesViewportContainer/TilesViewport
@onready var player = $TilesViewportContainer/TilesViewport/YSort/Player
@onready var enemy_generator = $TilesViewportContainer/TilesViewport/YSort/EnemyGenerator
@onready var dungeon_generator = $TilesViewportContainer/TilesViewport/YSort/DungeonGenerator

@onready var knight_class = preload("res://scenes/entities/player/knight/knight_class.tres")
@onready var wizard_class = preload("res://scenes/entities/player/wizard/wizard_class.tres")

var difficulty = 10
var ratio = 0

func _ready():
	player.initialize(knight_class, difficulty, Vector2(2.5 * Constants.TILE_SIZE, 5.5 * Constants.TILE_SIZE))
	enemy_generator.difficulty = difficulty
	dungeon_generator.difficulty = difficulty
	
func _process(_delta):
	var viewport = get_viewport_rect()
	var new_ratio = viewport.size.x / tiles_viewport.size.x
	if new_ratio != ratio:
		ratio = new_ratio
		tiles_viewport_container.scale = Vector2(ratio, ratio)
	
