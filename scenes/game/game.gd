extends Node2D

@onready var tiles_viewport_container = $TilesViewportContainer
@onready var tiles_viewport = $TilesViewportContainer/TilesViewport
@onready var y_sort = $TilesViewportContainer/TilesViewport/YSort
@onready var player = $TilesViewportContainer/TilesViewport/YSort/Player
@onready var camera = $TilesViewportContainer/TilesViewport/YSort/Player/Camera

var ratio = 0

func _ready():
	var dungeon_generator = load("res://scenes/dungeons/%s/dungeon_generator.tscn" % (GameState.dungeon.to_lower().replace(" ", "_"))).instantiate()
	y_sort.add_child(dungeon_generator)
	y_sort.move_child(dungeon_generator, 0)
	
	var dungeon_background = load("res://scenes/dungeons/%s/dungeon_background.tscn" % (GameState.dungeon.to_lower().replace(" ", "_"))).instantiate()
	camera.add_child(dungeon_background)
	
	var player_class = load("res://scenes/entities/player/%s/player_class.tres" % (GameState.character.to_lower().replace(" ", "_")))
	player.initialize(player_class, Vector2(0.5 * Constants.TILE_SIZE, 0.5 * Constants.TILE_SIZE))
	
func _process(_delta):
	var viewport = get_viewport_rect()
	var new_ratio = viewport.size.x / tiles_viewport.size.x
	if new_ratio != ratio:
		ratio = new_ratio
		tiles_viewport_container.scale = Vector2(ratio, ratio)
	
