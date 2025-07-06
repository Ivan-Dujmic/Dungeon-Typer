extends Entity
class_name Boss

@onready var ui = get_node("/root/Game/UI")
@onready var text_controller = get_node("/root/Game/TextController")
@onready var health_bar = $"HealthBar"
@onready var action_timer = $"ActionTimer"
var typing_text 

var action_cooldown: float

var target: Entity
var target_in_range = true

func update_health():
	health_bar.update_health(float(health) / max_health)

func set_target(new_target: Entity):
	target = new_target
	
func _on_range_area_body_entered(_body: Node2D):
	return

func _on_range_area_body_exited(_body: Node2D):
	return
	
func _on_action_timer_timeout():
	return
		
func die():
	queue_free()
	Signals.boss_defeated.emit()

# Position should be a tile coordinate
func initialize(class_init: BossClass, position_init: Vector2i):
	health_bar = $"HealthBar"
	max_health = class_init.max_health * GameState.difficulty
	health = max_health
	health_regen = class_init.health_regen
	attack = class_init.attack
	action_range = class_init.action_range
	speed = class_init.speed * GameState.difficulty
	action_cooldown = class_init.action_cooldown
	
	range_area.set_range(action_range)
	navigation_agent.target_desired_distance = action_range - 2

	action_timer.wait_time = action_cooldown
	
	animated_sprite.sprite_frames = class_init.animation_frames
	
	global_position = (Vector2(position_init) + Vector2(0.5, 0.5)) * Constants.TILE_SIZE
	
	typing_text = ui.create_boss_tt(self)
	
func _ready():
	return

func _physics_process(_delta):
	return
