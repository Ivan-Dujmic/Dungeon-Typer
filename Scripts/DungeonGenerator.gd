extends Node2D

@onready var floor_layer = $Floor
@onready var wall_layer = $Walls

var rng = RandomNumberGenerator.new()
# Storing tile positions as a map so we can check it's surroundings when drawing textures
# The map value is useless as we are only checking if the key exists in the map which effictively makes this map a set 
# (there are no sets in GDScript)
var floor_tiles: Dictionary[Vector2i, bool] = {}
var wall_tiles: Dictionary[Vector2i, bool] = {}

# Also remember tiles sorted by the x coordinate for faster cleanup
var x_sorted_floor_tiles: Dictionary[int, Array]
var x_sorted_wall_tiles: Dictionary[int, Array]

var highest_generated_x
var highest_erased_x

func init_dungeon_start():
	# Floor
	for x in range(1, 20):
		if not x_sorted_floor_tiles.has(x):
			x_sorted_floor_tiles[x] = []
		for y in range(4, 7):
			floor_tiles[Vector2i(x,y)] = true
			x_sorted_floor_tiles[x].push_back(y)
	
	# Upper and lower walls
	for x in range(0, 20):
		if not x_sorted_wall_tiles.has(x):
			x_sorted_wall_tiles[x] = []
		wall_tiles[Vector2i(x, 3)] = true
		x_sorted_wall_tiles[x].push_back(3)
		wall_tiles[Vector2i(x, 7)] = true
		x_sorted_wall_tiles[x].push_back(7)
	
	# Left walls
	if not x_sorted_wall_tiles.has(0):
		x_sorted_wall_tiles[0] = []
	for y in range(4,7):
		wall_tiles[Vector2i(0, y)] = true
		x_sorted_wall_tiles[0].push_back(y)
		
	highest_generated_x = 19
	highest_erased_x = -1

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
			wall_layer.set_cell(pos, 0, texture_cords)
			
# Generate more dungeon until and on specific x
func generate_to_x_line(new_x: int):
	if new_x > highest_generated_x:
		for x in range(highest_generated_x + 1, new_x + 1):
			x_sorted_wall_tiles[x] = []
			x_sorted_floor_tiles[x] = []
			wall_tiles[Vector2i(x, 3)] = true
			x_sorted_wall_tiles[x].push_back(3)
			floor_tiles[Vector2i(x, 4)] = true
			x_sorted_floor_tiles[x].push_back(4)
			floor_tiles[Vector2i(x, 5)] = true
			x_sorted_floor_tiles[x].push_back(5)
			floor_tiles[Vector2i(x, 6)] = true
			x_sorted_floor_tiles[x].push_back(6)
			wall_tiles[Vector2i(x, 7)] = true
			x_sorted_wall_tiles[x].push_back(7)
			# TODO: OPTIMIZE
	draw_all_tiles()
	
# Erase tiles before and on specific x (because the player can't go back)
func erase_to_x_line(new_x: int):
	if new_x > highest_erased_x:
		for x in range(highest_erased_x + 1, new_x + 1):
			if x_sorted_floor_tiles.has(x):
				for y in x_sorted_floor_tiles[x]:
					floor_layer.set_cell(Vector2i(x, y), -1)
					floor_tiles.erase(Vector2i(x, y))
				x_sorted_floor_tiles.erase(x)
			if x_sorted_wall_tiles.has(x):
				for y in x_sorted_wall_tiles[x]:
					wall_layer.set_cell(Vector2i(x, y), -1)
					wall_tiles.erase(Vector2i(x, y))
				x_sorted_wall_tiles.erase(x)

func _ready():
	init_dungeon_start()
	draw_all_tiles()
