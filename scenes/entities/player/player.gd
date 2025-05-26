extends CharacterBody2D

@onready var health_bar = get_node("/root/Game/UI/UIHealthBar")
@onready var dungeon_generator = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/DungeonGenerator")
@onready var range_area = $RangeArea
@onready var text_controller = get_node("/root/Game/TextController")
@onready var animated_sprite = $AnimatedSprite
@onready var navigation_agent = $NavigationAgent

const TILE_SIZE = 16
var target = Vector2(2.5 * TILE_SIZE, 5.5 * TILE_SIZE)	# Target location
var last_position = target

var difficulty

signal health_changed(health_ratio: float)

# Stats
var max_health: int
var health: int:	# Current health
	set(value):
		health = clamp(value, 0, max_health)
		emit_signal("health_changed", float(health) / max_health)
var health_regen: int	# Health regen per second
var attack: int	# Attack power
var action_range: int	# Pixel range in which the player can performs actions
var speed: float	# Movement speed

func move(move_amount: Vector2):
	target += move_amount * speed
	
func take_damage(damage: int):
	health -= damage
	
func _on_health_regen_timeout():
	health += health_regen

func _on_range_area_body_entered(body: Node2D):
	if body is Skeleton:
		text_controller.unblock(body.typing_text)

func _on_range_area_body_exited(body: Node2D):
	if body is Skeleton:
		text_controller.block(body.typing_text)

func initialize_stats(init_difficulty):
	difficulty = init_difficulty
	
	max_health = 100
	health = 100
	health_regen = 1
	attack = 10
	action_range = 144
	speed = 160 / difficulty
	
	range_area.set_range(action_range)

func _ready():
	global_position = Vector2(2.5 * TILE_SIZE, 5.5 * TILE_SIZE)
	health_changed.connect(health_bar.update_health)

func _physics_process(_delta):
	if target:
		navigation_agent.target_position = target
		
		if not navigation_agent.is_navigation_finished():
			animated_sprite.play("moving")
			
			var next_path_point = navigation_agent.get_next_path_position()
			var direction = (next_path_point - global_position).normalized()
			velocity = direction * max(8, 2 * global_position.distance_to(target))
			move_and_slide()
			
			var current_tile_x = global_position.x / 16
			dungeon_generator.generate_to_x_line(current_tile_x + 20)
			dungeon_generator.erase_to_x_line(current_tile_x - 10)

			animated_sprite.scale.x = - 1 if velocity.x < 0 else 1	# Looking direction
			
			if last_position == global_position:
				target = global_position
				
			last_position = global_position
		else:
			animated_sprite.play("idle")
			velocity = Vector2.ZERO
			animated_sprite.scale.x = 1
