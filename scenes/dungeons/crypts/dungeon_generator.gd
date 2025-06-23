extends DungeonGenerator
	
# Used in multiple structures
func generate_straight(x: int, path: Path):
	@warning_ignore("integer_division")
	var top_y = path.y - path.width / 2
	if path.width % 2 == 1:
		top_y -= 1
	@warning_ignore("integer_division")
	var bottom_y = path.y + path.width / 2 + 1
	place_tile(x, top_y, "wall")
	place_tile(x, bottom_y, "wall")
	for y in range (top_y + 1, bottom_y):
		place_tile(x, y, "floor")
	
# Generate more dungeon until and on specific x
func generate_to_x_line(new_x: int):
	if new_x > highest_generated_x:
		var x = highest_generated_x + 1
		while x <= new_x:
			for path in paths_y:
				if path.structure == "":
					path.structure = roll_structure()
					path.time = 0
				
				match path.structure:
					"straight":
						generate_straight(x, path)
						path.finish_structure()
					"offset":
						match path.time:
							0:
								path.flags["direction"] = "up" if randi() % 2 else "down"
								if path.flags["direction"] == "up":
									@warning_ignore("integer_division")
									var top_y = path.y - path.width / 2 - 1
									if path.width % 2 == 1:
										top_y -= 1
									place_tile(x, top_y, "wall")
								else:
									@warning_ignore("integer_division")
									var bottom_y = path.y + path.width / 2 + 2
									place_tile(x, bottom_y, "wall")
								path.time += 1
							1:
								if path.flags["direction"] == "up" and path.width % 2 == 1:
									path.y -= 1
								elif path.flags["direction"] == "down" and path.width % 2 == 0:
									path.y += 1
								path.time += 1
								path.width += 1
							2:
								path.width -= 1
								if path.flags["direction"] == "up":
									if path.width % 2 == 0:
										path.y -= 1
									@warning_ignore("integer_division")
									var bottom_y = path.y + path.width / 2 + 2
									place_tile(x, bottom_y, "wall")
								else:
									if path.width % 2 == 1:
										path.y += 1
									@warning_ignore("integer_division")
									var top_y = path.y - path.width / 2 - 1
									if path.width % 2 == 1:
										top_y -= 1
									place_tile(x, top_y, "wall")
								path.finish_structure()
								
						generate_straight(x, path)
					"width_change":
						match path.time:
							0:
								generate_straight(x, path)
								path.time += 1
							1:
								var direction = "up" if randi() % 2 else "down"
								var change
								if path.width == 2:
									change = "up"
								elif path.width == 6:
									change = "down"
								else:
									change = "up" if randi() % 2 else "down"
									
								if change == "up":
									if direction == "up":
										@warning_ignore("integer_division")
										var top_y = path.y - path.width / 2 - 1
										if path.width % 2 == 1:
											top_y -= 1
										place_tile(x, top_y, "wall")
										generate_straight(x, path)
										if path.width % 2 == 1:
											path.y -= 1
									else:
										@warning_ignore("integer_division")
										var bottom_y = path.y + path.width / 2 + 2
										place_tile(x, bottom_y, "wall")
										generate_straight(x, path)
										if path.width % 2 == 0:
											path.y += 1
									path.width += 1
								else:	# down change
									path.width -= 1
									if direction == "up":
										if path.width % 2 == 0:
											path.y -= 1
										@warning_ignore("integer_division")
										var bottom_y = path.y + path.width / 2 + 2
										place_tile(x, bottom_y, "wall")
										generate_straight(x, path)
									else:
										if path.width % 2 == 1:
											path.y += 1
										@warning_ignore("integer_division")
										var top_y = path.y - path.width / 2 - 1
										if path.width % 2 == 1:
											top_y -= 1
										place_tile(x, top_y, "wall")
										generate_straight(x, path)
								path.time += 1
							2:
								generate_straight(x, path)
								path.finish_structure()
					"turn":
						if path.time == 0:
							generate_straight(x, path)
							path.flags["direction"] = "up" if randi() % 2 else "down"
							path.flags["length"] = 2 + randi() % 6	# 2 - 7
							path.time += 1
						elif path.time == 1:
							generate_straight(x, path)
							var top_y
							var bottom_y
							if path.flags["direction"] == "up":
								top_y = path.y - path.width / 2 - path.flags["length"]
								bottom_y = path.y - path.width / 2 - 1
								if path.width % 2 == 1:
									top_y -= 1
									bottom_y -= 1
							else:
								top_y = path.y + path.width / 2 + 2
								bottom_y = path.y + path.width / 2 + 1 + path.flags["length"]
							for y in range(top_y, bottom_y + 1):
								place_tile(x, y, "wall")
							path.time += 1
						elif path.time <= path.width + 1:
							var top_y
							var bottom_y
							if path.flags["direction"] == "up":
								top_y = path.y - path.width / 2 - path.flags["length"]
								if path.width % 2 == 1:
									top_y -= 1
								bottom_y = path.y + path.width / 2 + 1
							else:
								top_y = path.y - path.width / 2
								if path.width % 2 == 1:
									top_y -= 1
								bottom_y = path.y + path.width / 2 + 1 + path.flags["length"]
							place_tile(x, top_y, "wall")
							place_tile(x, bottom_y, "wall")
							for y in range(top_y + 1, bottom_y):
								place_tile(x, y, "floor")
							path.time += 1
						elif path.time == path.width + 2:
							if path.flags["direction"] == "up":
								path.y -= path.flags["length"]
							else:
								path.y += path.flags["length"]
								
							generate_straight(x, path)
							var top_y
							var bottom_y
							if path.flags["direction"] == "up":
								top_y = path.y + path.width / 2 + 2
								bottom_y = path.y + path.width / 2 + 1 + path.flags["length"]
							else:
								top_y = path.y - path.width / 2 - path.flags["length"]
								bottom_y = path.y - path.width / 2 - 1
								if path.width % 2 == 1:
									top_y -= 1
									bottom_y -= 1
							for y in range(top_y, bottom_y + 1):
								place_tile(x, y, "wall")
							path.time += 1
						elif path.time == path.width + 3:
							generate_straight(x, path)
							path.finish_structure()
					"split":
						pass
					"big_empty":
						pass
					"double":
						pass
					"pillars":
						pass
						
			x += 1
		highest_generated_x = new_x
	
	draw_to_x_tiles(new_x - 1)

func initialize():
	max_paths = 3
	structure_weights = {
		"straight": 100,	# No change
		"offset": 10,	# Offset up or down by one
		"width_change": 7,	# Change width
		"turn": 4,	# Go up or down a few tiles
		#"split": 1,	# Diverging paths -> (2x) turn + straight
		#"big_empty": 1,	# Big empty room with possible diverging paths
		#"double": 1,	# Split corridors by a middle wall
		#"pillars": 1,	# Repeating pillars in 2 rows
	}
	calculate_total_weight()
	paths_y.push_back(Path.new(0, 3))
	
	# Left walls
	for y in range(-2,3):
		place_tile(-2, y, "wall")
		
	# 2 more x lines
	for x in range(-1, 1):
		place_tile(x, -2, "wall")
		place_tile(x, 2, "wall")
		for y in range(-1, 2):
			place_tile(x, y, "floor")
		
	highest_generated_x = 0
	highest_erased_x = -1
	highest_drawn_x = -3
		
	draw_to_x_tiles(-1)
	
