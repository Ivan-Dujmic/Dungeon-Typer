extends Node2D
class_name DungeonGenerator

@onready var dungeon_renderer: DungeonRenderer = $DungeonRenderer
@onready var navigation_region: NavigationRegion2D = $NavigationRegion
@onready var floor_layer: TileMapLayer = $NavigationRegion/Floor
@onready var wall_layer: TileMapLayer = $Walls

@onready var enemy_generator = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/EnemyGenerator")
@onready var player: Player = get_node("/root/Game/TilesViewportContainer/TilesViewport/YSort/Player")
@onready var ui = get_node("/root/Game/UI")

# We don't want to spawn enemies immediately
var can_spawn: bool = false

var rng = RandomNumberGenerator.new()

# Storing tile positions as a map so we can check it's surroundings when drawing textures
# The map value is useless as we are only checking if the key exists in the map which effictively makes this map a set 
# (there are no sets in GDScript)
var floor_tiles: Dictionary[Vector2i, bool] = {}
var wall_tiles: Dictionary[Vector2i, bool] = {}

# Also remember tiles sorted by the x coordinate for faster cleanup
var x_sorted_floor_tiles: Dictionary[int, Array] = {}
var x_sorted_wall_tiles: Dictionary[int, Array] = {}

var highest_generated_x: int
var highest_erased_x: int
var highest_drawn_x: int

# Dungeons structures and weights in roll to build them on each x draw
var structure_weights: Dictionary[String, int] = {}
var total_weight: int

# x line at which the final challenge/boss room spawns
var final_x

# Used to know when to merge paths (based on y and width)
# Also to keep track of path count to not go overboard
var paths_y: Array[Path] = []

var max_paths: int = 1

# We don't want to calculate on every roll_structure, so we recalculate on new structures
func calculate_total_weight():
	total_weight = 0
	for weight in structure_weights.values():
		total_weight += weight

func roll_structure() -> String:
	var rand = randi() % total_weight
	var sum = 0
	
	for key in structure_weights.keys():
		sum += structure_weights[key]
		if rand < sum:
			return key
			
	return ""	# Shouldn't happen if careful!

# Draws textures for tiles until x
# Should be called for x only once tiles for x+1 were generated
func draw_to_x_tiles(new_x: int):
	if new_x > highest_drawn_x:
		for x in range(highest_drawn_x + 1, new_x + 1):
			if x_sorted_floor_tiles.has(x):
				for y in x_sorted_floor_tiles[x]:
					# Pick random floor texture
					var texture_cords = dungeon_renderer.floor()
					floor_layer.set_cell(Vector2i(x, y), 0, texture_cords)
			if x_sorted_wall_tiles.has(x):
				for y in x_sorted_wall_tiles[x]:
					var texture_cords = Vector2i(-1, -1)
			
					if floor_tiles.has(Vector2i(x, y)): # Wall on tile (intersected structures -> remove wall to merge)
						pass	# Just don't draw
					elif floor_tiles.has(Vector2i(x, y + 1)):  # Tile down
						texture_cords = dungeon_renderer.wall_top()
					elif floor_tiles.has(Vector2i(x, y - 1)):  # Tile up
						if floor_tiles.has(Vector2i(x + 1, y)):  # Tile right:
							texture_cords = dungeon_renderer.wall_bottom_left_outer()
						elif floor_tiles.has(Vector2i(x - 1, y)):  # Tile left:
							texture_cords = dungeon_renderer.wall_bottom_right_outer()
						else:
							texture_cords = dungeon_renderer.wall_bottom()
					elif floor_tiles.has(Vector2i(x + 1, y)):  # Tile right
						texture_cords = dungeon_renderer.wall_left()
					elif floor_tiles.has(Vector2i(x - 1, y)):  # Tile left
						texture_cords = dungeon_renderer.wall_right()
					elif floor_tiles.has(Vector2i(x + 1, y + 1)):  # Tile down right
						texture_cords = dungeon_renderer.wall_top_left()
					elif floor_tiles.has(Vector2i(x - 1, y + 1)):  # Tile down left
						texture_cords = dungeon_renderer.wall_top_right()
					elif floor_tiles.has(Vector2i(x + 1, y - 1)):  # Tile up right
						texture_cords = dungeon_renderer.wall_bottom_left_inner()
					elif floor_tiles.has(Vector2i(x - 1, y - 1)):  # Tile up left
						texture_cords = dungeon_renderer.wall_bottom_right_inner()
					
					if texture_cords != Vector2i(-1, -1):
						wall_layer.set_cell(Vector2i(x, y), 0, texture_cords)
					
	highest_drawn_x = new_x
	
func place_tile(x: int, y: int, tile: String):
	match tile:
		"wall":
			if not x_sorted_wall_tiles.has(x):
				x_sorted_wall_tiles[x] = []
			wall_tiles[Vector2i(x, y)] = true
			x_sorted_wall_tiles[x].push_back(y)
		"floor":
			if can_spawn and paths_y[0].structure != "final":
				if randf() < 0.7:
					enemy_generator.attempt_enemy_spawn("Skeleton", 0.1, Vector2i(x, y))
				else:
					enemy_generator.attempt_enemy_spawn("Flaming Skull", 0.1, Vector2i(x, y))
			if not x_sorted_floor_tiles.has(x):
				x_sorted_floor_tiles[x] = []
			floor_tiles[Vector2i(x, y)] = true
			x_sorted_floor_tiles[x].push_back(y)
	
# Generate more dungeon until and on specific x
func generate_to_x_line(_new_x: int):
	pass
	
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

func initialize():
	pass
	
func _on_entity_moved(entity: Entity, entity_pos: Vector2):
	var current_tile_x = entity_pos.x / 16
	if entity is Player:
		generate_to_x_line(current_tile_x + 20)
		erase_to_x_line(current_tile_x - 10)
	elif entity is Enemy:
		if current_tile_x <= highest_erased_x:
			entity.queue_free()

func _ready():
	initialize()
	Signals.connect("entity_moved", Callable(self, "_on_entity_moved"))
