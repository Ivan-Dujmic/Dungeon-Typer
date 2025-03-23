extends Node2D

@onready var floor_layer = $Floor
@onready var walls_layer = $Walls

var rng = RandomNumberGenerator.new()
# Storing tile positions as a map so we can check it's surroundings when drawing textures
# The map value is useless as we are only checking if the key exists in the map which effictively makes this map a set 
# (there are no sets in GDScript)
var floor_tiles: Dictionary[Vector2i, bool] = {}
var wall_tiles: Dictionary[Vector2i, bool] = {}

func init_dungeon_start():
	# Floor
	for x in range(1, 20):
		for y in range(4, 7):
			floor_tiles[Vector2i(x,y)] = true
	
	# Upper and lower walls
	for x in range(0, 20):
		wall_tiles[Vector2i(x, 3)] = true
		wall_tiles[Vector2i(x, 7)] = true
	
	# Left walls
	for y in range(4,7):
		wall_tiles[Vector2i(0, y)] = true

func draw_all_tiles():
	for pos in floor_tiles:
		# Pick random floor texture
		var texture_cords = Vector2i(rng.randi_range(6, 9), rng.randi_range(0, 2))
		floor_layer.set_cell(pos, 0, texture_cords)
		
	for pos in wall_tiles:
		var texture_cords = Vector2i(-1, -1)
		
		if floor_tiles.has(Vector2i(pos.x, pos.y + 1)):  # Tile down
			texture_cords = Vector2i(rng.randi_range(1, 4), 0)
		elif floor_tiles.has(Vector2i(pos.x, pos.y - 1)):  # Tile up
			texture_cords = Vector2i(rng.randi_range(1, 4), 4)
		elif floor_tiles.has(Vector2i(pos.x + 1, pos.y)):  # Tile right
			texture_cords = Vector2i(0, rng.randi_range(0, 3))
		elif floor_tiles.has(Vector2i(pos.x - 1, pos.y)):  # Tile left
			texture_cords = Vector2i(5, rng.randi_range(0, 3))
		elif floor_tiles.has(Vector2i(pos.x + 1, pos.y + 1)):  # Tile down right
			texture_cords = Vector2i(0, rng.randi_range(0, 3))
		elif floor_tiles.has(Vector2i(pos.x - 1, pos.y + 1)):  # Tile down left
			texture_cords = Vector2i(5, rng.randi_range(0, 3))
		elif floor_tiles.has(Vector2i(pos.x + 1, pos.y - 1)):  # Tile up right
			texture_cords = Vector2i(0, 4)
		elif floor_tiles.has(Vector2i(pos.x - 1, pos.y - 1)):  # Tile up left
			texture_cords = Vector2i(5, 4)

		if texture_cords != Vector2i(-1, -1):
			walls_layer.set_cell(pos, 0, texture_cords)

func _ready():
	print("DungeonGenerator ready")
	init_dungeon_start()
	draw_all_tiles()
