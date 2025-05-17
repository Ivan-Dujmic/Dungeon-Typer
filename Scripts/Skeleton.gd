extends Node2D
class_name Skeleton

@onready var sprite

var TILE_SIZE = 16

var rng = RandomNumberGenerator.new()

# Position should be a tile coordinate
func initialize(position_init: Vector2i):
	sprite = $Sprite
	
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://2D Pixel Dungeon Asset Pack/character and tileset/Dungeon_Character.png")
	atlas.region = Rect2(64 + rng.randi_range(0, 2) * TILE_SIZE, 48, 16, 16)
	
	sprite.texture = atlas
	sprite.scale.x = -1
	position = Vector2(position_init * TILE_SIZE)
	
func _ready():
	return
