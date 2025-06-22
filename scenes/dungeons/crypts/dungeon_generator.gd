extends DungeonGenerator

var diverging_path_chance = 0.1	# 1 = 100%
	
# Generate more dungeon until and on specific x
func generate_to_x_line(new_x: int):
	if new_x > highest_generated_x:
		var x = highest_generated_x + 1
		while x <= new_x:
			if rng.randf() <= diverging_path_chance:
				for x2 in range(x, x+3):
					x_sorted_wall_tiles[x2] = []
					x_sorted_floor_tiles[x2] = []
					floor_tiles[Vector2i(x2, -1)] = true
					x_sorted_floor_tiles[x2].push_back(-1)
					floor_tiles[Vector2i(x2, 0)] = true
					x_sorted_floor_tiles[x2].push_back(0)
					floor_tiles[Vector2i(x2, 1)] = true
					x_sorted_floor_tiles[x2].push_back(1)
					wall_tiles[Vector2i(x2, 2)] = true
					x_sorted_wall_tiles[x2].push_back(2)
					if can_spawn:
						enemy_generator.attempt_enemy_spawn("Skeleton", 0.3, Vector2i(x2, rng.randi_range(-1, 1)))
				for y in range(-7, -1):
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
				wall_tiles[Vector2i(x, -2)] = true
				x_sorted_wall_tiles[x].push_back(-2)
				floor_tiles[Vector2i(x, -1)] = true
				x_sorted_floor_tiles[x].push_back(-1)
				floor_tiles[Vector2i(x, 0)] = true
				x_sorted_floor_tiles[x].push_back(0)
				floor_tiles[Vector2i(x, 1)] = true
				x_sorted_floor_tiles[x].push_back(1)
				wall_tiles[Vector2i(x, 2)] = true
				x_sorted_wall_tiles[x].push_back(2)
				
				if can_spawn:
					enemy_generator.attempt_enemy_spawn("Skeleton", 0.3, Vector2i(x, rng.randi_range(-1, 1)))
			
			x += 1
				
		highest_generated_x = new_x
	
	draw_to_x_tiles(new_x - 1)

func initialize():
	max_paths = 3
	structure_weights = {
		"straight": 100,	# No change
		"offset": 10,	# Offset up or down by one
		"width_change": 7,	# Change width
		"turn": 3,	# Go up or down a few tiles
		"split": 1,	# Diverging paths -> (2x) turn + straight
		"big_empty": 1,	# Big empty room with possible diverging paths
		"double": 1,	# Split corridors by a middle wall
		"pillars": 1,	# Repeating pillars in 2 rows
	}
	paths_y.push_back({"y": 0, "width": 3})
	
	# Left walls
	if not x_sorted_wall_tiles.has(-2):
		x_sorted_wall_tiles[-2] = []
	for y in range(-2,3):
		wall_tiles[Vector2i(-2, y)] = true
		x_sorted_wall_tiles[-2].push_back(y)
		
	highest_generated_x = -2
	highest_erased_x = -3
	highest_drawn_x = -3
	
	generate_to_x_line(18)
