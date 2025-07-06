extends Entity
class_name Enemy

@onready var ui = get_node("/root/Game/UI")
@onready var item_drops = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/ItemDrops")
@onready var health_bar = $"HealthBar"
@onready var action_timer = $"ActionTimer"
var typing_text 

@onready var item_drop = preload("res://scenes/items/item_drop.tscn")

var action_cooldown: float
@export var loot_table: LootTable

var target: Entity
var target_in_range = false

func update_health():
	health_bar.update_health(float(health) / max_health)

func set_target(new_target: Entity):
	target = new_target
	
func _on_range_area_body_entered(body: Node2D):
	if body == target:
		target_in_range = true

func _on_range_area_body_exited(body: Node2D):
	if body == target:
		target_in_range = false
	
func _on_action_timer_timeout():
	if target_in_range:
		target.take_damage(attack)
		
func die():
	if not GameState.boss_active:
		var drops = loot_table.roll()
		for drop in drops:
			var new_drop = item_drop.instantiate()
			item_drops.add_child(new_drop)
			new_drop.initialize(drop, global_position + Vector2((randf()-0.5)*20, (randf()-0.5)*20))
	
	GameState.run_enemies_defeated += 1
	queue_free()

# Position should be a tile coordinate
func initialize(class_init: EnemyClass, position_init: Vector2i):
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
	
	typing_text = ui.create_enemy_tt(self)
	
func _ready():
	return

func _physics_process(_delta):
	if target:
		if global_position.distance_to(target.global_position) < 256:
			navigation_agent.target_position = target.global_position
		
		if not navigation_agent.is_navigation_finished():
			animated_sprite.play("moving")
			
			var next_path_point = navigation_agent.get_next_path_position()
			var direction = (next_path_point - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
			
			Signals.emit_signal("entity_moved", self, global_position)

			animated_sprite.scale.x = - 1 if velocity.x <= 0 else 1	# Looking direction
		else:
			animated_sprite.play("idle")
			velocity = Vector2.ZERO
