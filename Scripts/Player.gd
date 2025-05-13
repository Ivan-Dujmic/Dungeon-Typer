extends Node2D

@onready var dungeon_generator = $"../DungeonGenerator"
@onready var background = $"../Background"

const TILE_SIZE = 16
var new_position = Vector2(2 * TILE_SIZE, 5 * TILE_SIZE)	# The position that the character should move to

func move(move_amount: Vector2):
	var direction = move_amount.normalized()
	var distance = move_amount.length()
	var step_size = 1.0  # Move 1 pixel per step
	var moved_distance = 0.0

	while moved_distance < distance:
		var step = direction * step_size
		var next_position = new_position + step
		var next_tile = Vector2i(0, 0)
		next_tile.x = ceil(next_position.x / TILE_SIZE) if direction.x > 0 else floor(next_position.x / TILE_SIZE)
		next_tile.y = ceil(next_position.y / TILE_SIZE) if direction.y > 0 else floor(next_position.y / TILE_SIZE)

		if dungeon_generator.wall_tiles.has(next_tile):
			# Stop just before hitting the wall
			return

		new_position = next_position
		moved_distance += step_size
		
		# Generate and erase dungeon
		dungeon_generator.generate_to_x_line(next_tile.x + 20)
		dungeon_generator.erase_to_x_line(next_tile.x - 10)

func _ready():
	position = Vector2(2 * TILE_SIZE, 5 * TILE_SIZE)

func _process(delta):
	if position != new_position:
		var diff = new_position - position
		var move_amount = Vector2(0, 0)
		
		if (diff.x != 0):
			move_amount.x = max(diff.sign().x, floor(diff.x / 5)) * delta * 15
		if (diff.y != 0):
			move_amount.y = max(diff.sign().y, floor(diff.y / 5)) * delta * 15
		
		if abs(move_amount.x) > abs(diff.x):
			move_amount.x = diff.x
		if abs(move_amount.y) > abs(diff.y):
			move_amount.y = diff.y
			
		position += move_amount
		background.position += move_amount
