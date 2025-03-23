extends Node2D

@onready var dungeon_generator = $DungeonGenerator
@onready var player = $Player

func _ready():
	print("Game ready")
