extends Sprite2D

@onready var dungeon_generator = $"../DungeonGenerator"
@onready var background = $"../Background"

const TILE_SIZE = 16

var new_position = Vector2(2 * TILE_SIZE, 5 * TILE_SIZE)	# The position that the character should move to

func move(move_amount: Vector2):
	#TODO: add collision detection
	new_position += move_amount

func _ready():
	print("Player ready")
	position = Vector2(2 * TILE_SIZE, 5 * TILE_SIZE)

func _process(delta):
	if position != new_position:
		var diff = new_position - position
		var diff_sign = diff / abs(diff)	# Stores 1 or -1 for each coordinate depending on its sign
		var move_amount = Vector2(0, 0)
		
		if (diff.x != 0):
			move_amount.x = max(diff_sign.x, floor(diff.x / 5)) * delta * 15
		if (diff.y != 0):
			move_amount.y = max(diff_sign.y, floor(diff.y / 5)) * delta * 15
		
		if abs(move_amount.x) > abs(diff.x):
			move_amount.x = diff.x
		if abs(move_amount.y) > abs(diff.y):
			move_amount.y = diff.y
			
		position += move_amount
		background.position += move_amount
