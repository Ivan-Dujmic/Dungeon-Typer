extends Node2D

@onready var dungeon_generator = $TilesViewportContainer/TilesViewport/DungeonGenerator
@onready var player = $TilesViewportContainer/TilesViewport/Player

func _ready():
	print("Game ready")
