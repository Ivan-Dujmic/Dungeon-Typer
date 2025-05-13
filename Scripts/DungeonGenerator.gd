extends Node2D

@onready var floor_layer = $Floor
@onready var wall_layer = $Walls

@onready var enemy_generator = $"../EnemyGenerator"

var rng = RandomNumberGenerator.new()
var diverging_path_chance = 0.1	# 1 = 100%

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
var highest_drawn_x

# Draws textures for tiles until x
# Should be called for x only once tiles for x+1 were generated
func draw_to_x_tiles(new_x: int):
	if new_x > highest_drawn_x:
		for x in range(highest_drawn_x + 1, new_x + 1):
			if x_sorted_floor_tiles.has(x):
				for y in x_sorted_floor_tiles[x]:
					# Pick random floor texture
					var texture_cords = Vector2i(rng.randi_range(6, 9), rng.randi_range(0, 2))
					floor_layer.set_cell(Vector2i(x, y), 0, texture_cords)
			if x_sorted_wall_tiles.has(x):
				for y in x_sorted_wall_tiles[x]:
					var texture_cords = Vector2i(-1, -1)
		
					if floor_tiles.has(Vector2i(x, y + 1)):  # Tile down
						texture_cords = Vector2i(rng.randi_range(1, 4), 0)
					elif floor_tiles.has(Vector2i(x, y - 1)):  # Tile up
						texture_cords = Vector2i(rng.randi_range(1, 4), 4)
					elif floor_tiles.has(Vector2i(x + 1, y)):  # Tile right
						texture_cords = Vector2i(0, rng.randi_range(0, 3))
					elif floor_tiles.has(Vector2i(x - 1, y)):  # Tile left
						texture_cords = Vector2i(5, rng.randi_range(0, 3))
					elif floor_tiles.has(Vector2i(x + 1, y + 1)):  # Tile down right
						texture_cords = Vector2i(0, rng.randi_range(0, 3))
					elif floor_tiles.has(Vector2i(x - 1, y + 1)):  # Tile down left
						texture_cords = Vector2i(5, rng.randi_range(0, 3))
					elif floor_tiles.has(Vector2i(x + 1, y - 1)):  # Tile up right
						texture_cords = Vector2i(0, 4)
					elif floor_tiles.has(Vector2i(x - 1, y - 1)):  # Tile up left
						texture_cords = Vector2i(5, 4)
					
					if texture_cords != Vector2i(-1, -1):
						wall_layer.set_cell(Vector2i(x, y), 0, texture_cords)
					
	highest_drawn_x = new_x
	
# Generate more dungeon until and on specific x
func generate_to_x_line(new_x: int):
	if new_x > highest_generated_x:
		var x = highest_generated_x + 1
		while x <= new_x:
			if rng.randf() <= diverging_path_chance:
				for x2 in range(x, x+3):
					x_sorted_wall_tiles[x2] = []
					x_sorted_floor_tiles[x2] = []
					floor_tiles[Vector2i(x2, 4)] = true
					x_sorted_floor_tiles[x2].push_back(4)
					floor_tiles[Vector2i(x2, 5)] = true
					x_sorted_floor_tiles[x2].push_back(5)
					floor_tiles[Vector2i(x2, 6)] = true
					x_sorted_floor_tiles[x2].push_back(6)
					wall_tiles[Vector2i(x2, 7)] = true
					x_sorted_wall_tiles[x2].push_back(7)
				for y in range(-2, 4):
					wall_tiles[Vector2i(x, y)] = true
					x_sorted_wall_tiles[x].push_back(y)
					floor_tiles[Vector2i(x+1, y)] = true
					x_sorted_floor_tiles[x+1].push_back(y)
					wall_tiles[Vector2i(x+2, y)] = true
					x_sorted_wall_tiles[x+2].push_back(y)
				x += 2	# Mark these tiles as generated
				if x > new_x:
					new_x = x
				
			else:
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
				
				enemy_generator.attempt_enemy_spawn("Skeleton", 0.1, Vector2i(x, rng.randi_range(4, 6)))
			
			x += 1
				
		highest_generated_x = new_x
	
	draw_to_x_tiles(new_x - 1)
	
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
	highest_erased_x = new_x

func init_dungeon_start():
	# Left walls
	if not x_sorted_wall_tiles.has(0):
		x_sorted_wall_tiles[0] = []
	for y in range(3,8):
		wall_tiles[Vector2i(0, y)] = true
		x_sorted_wall_tiles[0].push_back(y)
		
	highest_generated_x = 0
	highest_erased_x = -1
	highest_drawn_x = -1
	
	generate_to_x_line(20)

func _ready():
	init_dungeon_start()
