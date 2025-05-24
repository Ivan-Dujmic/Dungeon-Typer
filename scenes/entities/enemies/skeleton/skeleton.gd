extends CharacterBody2D
class_name Skeleton

@onready var animated_sprite = $AnimatedSprite
@onready var range_area = $RangeArea
@onready var navigation_agent = $NavigationAgent
@onready var health_bar = $HealthBar
@onready var ui = get_node("/root/Game/UI")
var typing_text 

signal health_changed(health_ratio: float)

const TILE_SIZE = 16

var rng = RandomNumberGenerator.new()

var target
var target_in_range = false

# Stats
var max_health: int
var health: int:	# Current health
	set(value):
		health = clamp(value, 0, max_health)
		emit_signal("health_changed", float(health) / max_health)
		if health == 0:
			die()
var health_regen: int	# Health regen per second
var attack: int	# Attack power
var action_range: int	# Pixel range in which the player can performs actions
var speed: float	# Movement speed

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
		
func take_damage(damage: int):
	health -= damage

func die():
	queue_free()

# Position should be a tile coordinate
func initialize(position_init: Vector2i, speed_init: float):
	# Position
	global_position = (Vector2(position_init) + Vector2(0.5, 0.5)) * TILE_SIZE
	
	# Init stats
	max_health = 20
	health = 20
	health_regen = 0
	attack = 10
	action_range = 15
	speed = speed_init
	
	# Set up action range
	range_area.set_range(action_range)
	navigation_agent.target_desired_distance = action_range - 2
	
	# Connect health bar
	health_changed.connect(health_bar.update_health)
	
	# Set up TypingText
	typing_text = ui.create_enemy_tt(self)
	
func _ready():
	return

func _physics_process(delta):
	if target:
		navigation_agent.target_position = target.global_position
		
		if not navigation_agent.is_navigation_finished():
			animated_sprite.play("moving")
			
			var next_path_point = navigation_agent.get_next_path_position()
			var direction = (next_path_point - global_position).normalized()
			velocity = direction * speed * delta * 50
			move_and_slide()

			animated_sprite.scale.x = - 1 if velocity.x <= 0 else 1	# Looking direction
		else:
			animated_sprite.play("idle")
			velocity = Vector2.ZERO
