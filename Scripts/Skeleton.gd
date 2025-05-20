extends CharacterBody2D
class_name Skeleton

@onready var range_area = $RangeArea
@onready var navigation_agent = $NavigationAgent

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
		target_in_range = true

func _on_range_area_body_exited(body: Node2D):
	if body == target:
		target_in_range = false
	
func _on_attack_timer_timeout():
	if target_in_range:
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
	navigation_agent.target_desired_distance = action_range - 2
	
func _ready():
	return

func _physics_process(delta):
	if (target):
		navigation_agent.target_position = target.global_position
		
		if not navigation_agent.is_navigation_finished():
			var next_path_point = navigation_agent.get_next_path_position()
			var direction = (next_path_point - global_position).normalized()
			velocity = direction * speed * delta * 50
			move_and_slide()

			sprite.scale.x = - 1 if velocity.x <= 0 else 1	# Looking direction
		else:
			velocity = Vector2.ZERO
