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
					floor_tiles[Vector2i(x2, 4)] = true
					x_sorted_floor_tiles[x2].push_back(4)
					floor_tiles[Vector2i(x2, 5)] = true
					x_sorted_floor_tiles[x2].push_back(5)
					floor_tiles[Vector2i(x2, 6)] = true
					x_sorted_floor_tiles[x2].push_back(6)
					wall_tiles[Vector2i(x2, 7)] = true
					x_sorted_wall_tiles[x2].push_back(7)
					if can_spawn:
						enemy_generator.attempt_enemy_spawn("Skeleton", 0.3, Vector2i(x2, rng.randi_range(4, 6)))
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
				
				if can_spawn:
					enemy_generator.attempt_enemy_spawn("Skeleton", 0.3, Vector2i(x, rng.randi_range(4, 6)))
			
			x += 1
				
		highest_generated_x = new_x
	
	draw_to_x_tiles(new_x - 1)

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
