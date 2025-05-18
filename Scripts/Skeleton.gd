extends CharacterBody2D
class_name Skeleton

var sprite

var rng = RandomNumberGenerator.new()

const TILE_SIZE = 16
var target

# Stats
var health
var health_regen
var attack
var attack_range
var speed

# Changes the enemy's target
func set_target(new_target):
	target = new_target

# Position should be a tile coordinate
func initialize(position_init: Vector2i, speed_init: float):
	sprite = $Sprite
	
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://2D Pixel Dungeon Asset Pack/character and tileset/Dungeon_Character.png")
	atlas.region = Rect2(64 + rng.randi_range(0, 2) * TILE_SIZE, 48, 16, 16)
	
	sprite.texture = atlas
	global_position = (Vector2(position_init) + Vector2(0.5, 0.5)) * TILE_SIZE
	sprite.centered = true
	
	speed = speed_init
	
func _ready():
	return

func _physics_process(delta):
	if (target):
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
			
		if move_and_slide():
			print("COLLISION")

		# Looking direction
		if direction.x < 0:
			sprite.scale.x = -1
		else:
			sprite.scale.x = 1
			sprite.offset = Vector2(0, 0)
		
	
