extends Node2D
class_name Game

@onready var tiles_viewport_container = $TilesViewportContainer
@onready var tiles_viewport = $TilesViewportContainer/TilesViewport
@onready var y_sort = $TilesViewportContainer/TilesViewport/YSort
@onready var player = $TilesViewportContainer/TilesViewport/YSort/Player
@onready var camera = $TilesViewportContainer/TilesViewport/YSort/Player/Camera
@onready var popup_ui = $PopupUI
@onready var text_controller = $TextController

var ratio = 0

func _game_over():
	popup_ui.load_panel("game_over")
	get_tree().paused = true
	
func _victory():
	popup_ui.load_panel("victory")
	get_tree().paused = true
	
func _modifier_open():
	text_controller.ignore = true
	popup_ui.load_panel("modifier")
	get_tree().paused = true
	
func _ready():
	var dungeon_generator = load("res://scenes/dungeons/%s/dungeon_generator.tscn" % (GameState.dungeon.to_lower().replace(" ", "_"))).instantiate()
	y_sort.add_child(dungeon_generator)
	y_sort.move_child(dungeon_generator, 0)
	
	var dungeon_background = load("res://scenes/dungeons/%s/dungeon_background.tscn" % (GameState.dungeon.to_lower().replace(" ", "_"))).instantiate()
	camera.add_child(dungeon_background)
	
	var player_class = load("res://scenes/entities/player/%s/player_class.tres" % (GameState.character.to_lower().replace(" ", "_")))
	player.initialize(player_class, Vector2(0.5 * Constants.TILE_SIZE, 0.5 * Constants.TILE_SIZE))
	
	GameState.modifier_roll_amount = 3
	GameState.boss_active = false
	
	player.player_died.connect(_game_over)
	Signals.boss_defeated.connect(_victory)
	Signals.modifier_selection.connect(_modifier_open)
	
func _process(_delta):
	var viewport = get_viewport_rect()
	var new_ratio = viewport.size.x / tiles_viewport.size.x
	if new_ratio != ratio:
		ratio = new_ratio
		tiles_viewport_container.scale = Vector2(ratio, ratio)
	
