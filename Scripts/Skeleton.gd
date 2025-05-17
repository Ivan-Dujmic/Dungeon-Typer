extends Node2D
class_name Skeleton

var sprite

var TILE_SIZE = 16

var rng = RandomNumberGenerator.new()

var target
var real_position	# Position = round(real_position) because of blur
var speed = 10

# Changes the enemy's target
func set_target(new_target):
	target = new_target

# Position should be a tile coordinate
func initialize(position_init: Vector2i):
	sprite = $Sprite
	
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://2D Pixel Dungeon Asset Pack/character and tileset/Dungeon_Character.png")
	atlas.region = Rect2(64 + rng.randi_range(0, 2) * TILE_SIZE, 48, 16, 16)
	
	sprite.texture = atlas
	real_position = Vector2(position_init * TILE_SIZE)
	position = round(real_position)
	
func _ready():
	return

func _process(delta):
	if (target):
		var diff = target.position - real_position

		# Move
		if abs(diff.x) > 8 or abs(diff.y) > 8:
			real_position += diff.normalized() * delta * speed
			position = round(real_position)
		
		# Looking direction
		if diff.x < 0:
			sprite.scale.x = -1
			sprite.offset = Vector2(-16, 0)
		else:
			sprite.scale.x = 1
			sprite.offset = Vector2(0, 0)
		
	
