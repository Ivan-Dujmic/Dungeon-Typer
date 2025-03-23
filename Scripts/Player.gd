extends Sprite2D

const TILE_SIZE = 16

func _ready():
	print("Player ready")
	position = Vector2(2 * TILE_SIZE, 5 * TILE_SIZE)
