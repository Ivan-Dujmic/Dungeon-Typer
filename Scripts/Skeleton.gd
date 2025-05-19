extends CharacterBody2D
class_name Skeleton

@onready var range_area = $RangeArea

var sprite

var rng = RandomNumberGenerator.new()

const TILE_SIZE = 16
var target
var target_in_range = false

# Stats
var max_health: int
var health: int
var health_regen: int
var attack: int
var action_range: int
var speed: float

# Changes the enemy's target
func set_target(new_target):
	target = new_target
	
func _on_range_area_body_entered(body: Node2D):
	if body == target:
		print("ENTER")
		target_in_range = true

func _on_range_area_body_exited(body: Node2D):
	if body == target:
		print("EXIT")
		target_in_range = false
	
func _on_attack_timer_timeout():
	if target_in_range:
		print("ATTACK")
		target.take_damage(attack)

# Position should be a tile coordinate
func initialize(position_init: Vector2i, speed_init: float):
	sprite = $Sprite
	
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://2D Pixel Dungeon Asset Pack/character and tileset/Dungeon_Character.png")
	atlas.region = Rect2(64 + rng.randi_range(0, 2) * TILE_SIZE, 48, 16, 16)
	
	sprite.texture = atlas
	global_position = (Vector2(position_init) + Vector2(0.5, 0.5)) * TILE_SIZE
	sprite.centered = true
	
	health = 20
	health_regen = 0
	attack = 10
	action_range = 15
	speed = speed_init
	
	range_area.set_range(action_range)
	
func _ready():
	return

func _physics_process(_delta):
	if (target):
		var diff = target.global_position - global_position
		var direction = diff.normalized()
		velocity = direction * speed
			
		if abs(diff.length()) > action_range - 2:
			move_and_slide()

		# Looking direction
		if direction.x < 0:
			sprite.scale.x = -1
		else:
			sprite.scale.x = 1
			sprite.offset = Vector2(0, 0)
		
