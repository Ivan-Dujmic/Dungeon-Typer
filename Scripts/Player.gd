extends CharacterBody2D

@onready var dungeon_generator = $"../DungeonGenerator"
@onready var range_area = $RangeArea

const TILE_SIZE = 16
var new_position = Vector2(2.5 * TILE_SIZE, 5.5 * TILE_SIZE)	# The position that the character should move to

var difficulty

# Stats
var health
var health_regen
var attack
var action_range
var speed

func move(move_amount: Vector2):
	new_position += move_amount * speed

func initialize_stats(init_difficulty):
	difficulty = init_difficulty
	
	health = 100
	health_regen = 2
	attack = 10
	action_range = 160
	speed = 160 / difficulty
	
	range_area.set_range(action_range)

func _ready():
	global_position = Vector2(2.5 * TILE_SIZE, 5.5 * TILE_SIZE)

func _physics_process(delta):
	if global_position != new_position:
		var diff = new_position - global_position	# Movement needed to get to the desired location
		var motion: Vector2	# Movement to be performed on this tick
		# The more distant the goal, the faster the movement
		motion.x = max(abs(diff.x) / 5, 1.0) * sign(diff.x) * delta * 15 if diff.x != 0.0 else 0.0
		motion.y = max(abs(diff.y) / 5, 1.0) * sign(diff.y) * delta * 15 if diff.y != 0.0 else 0.0
		var new_diff = new_position - global_position
		# Don't overshoot
		if new_diff.sign().x != diff.sign().x:
			motion.x = diff.x
		if new_diff.sign().y != diff.sign().y:
			motion.y = diff.y
			
		if move_and_collide(motion):	# Move and check if collided
			new_position = global_position
		
		var current_tile_x = global_position.x / 16
		dungeon_generator.generate_to_x_line(current_tile_x + 20)
		dungeon_generator.erase_to_x_line(current_tile_x - 10)
		
	
