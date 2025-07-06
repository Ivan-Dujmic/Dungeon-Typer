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
			if x > 15:
				can_spawn = true
			for path in paths_y:
				if path.structure == "":
					if x >= final_x:
						path.structure = "final"
					else:
						path.structure = roll_structure()
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
								@warning_ignore("integer_division")
								top_y = path.y - path.width / 2 - path.flags["length"]
								@warning_ignore("integer_division")
								bottom_y = path.y - path.width / 2 - 1
								if path.width % 2 == 1:
									top_y -= 1
									bottom_y -= 1
							else:
								@warning_ignore("integer_division")
								top_y = path.y + path.width / 2 + 2
								@warning_ignore("integer_division")
								bottom_y = path.y + path.width / 2 + 1 + path.flags["length"]
							for y in range(top_y, bottom_y + 1):
								place_tile(x, y, "wall")
							path.time += 1
						elif path.time <= path.width + 1:
							var top_y
							var bottom_y
							if path.flags["direction"] == "up":
								@warning_ignore("integer_division")
								top_y = path.y - path.width / 2 - path.flags["length"]
								if path.width % 2 == 1:
									top_y -= 1
								@warning_ignore("integer_division")
								bottom_y = path.y + path.width / 2 + 1
							else:
								@warning_ignore("integer_division")
								top_y = path.y - path.width / 2
								if path.width % 2 == 1:
									top_y -= 1
								@warning_ignore("integer_division")
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
								@warning_ignore("integer_division")
								top_y = path.y + path.width / 2 + 2
								@warning_ignore("integer_division")
								bottom_y = path.y + path.width / 2 + 1 + path.flags["length"]
							else:
								@warning_ignore("integer_division")
								top_y = path.y - path.width / 2 - path.flags["length"]
								@warning_ignore("integer_division")
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
						if path.time == 0:
							generate_straight(x, path)
							path.time += 1
						elif path.time == 1 or path.time == path.width + 10:
							generate_straight(x, path)
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 5
							for y in range(bottom_y - 4, bottom_y + 1):
								place_tile(x, y, "wall")
							for y in range(bottom_y - path.width - 9, bottom_y - path.width - 4):
								place_tile(x, y, "wall")
							path.time += 1
						elif path.time <= path.width + 9:
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 5
							place_tile(x, bottom_y, "wall")
							place_tile(x, bottom_y - path.width - 9, "wall")
							for y in range(bottom_y - path.width - 8, bottom_y):
								place_tile(x, y, "floor")
							path.time += 1
						elif path.time == path.width + 11:
							generate_straight(x, path)
							path.finish_structure()
					"double":
						if path.time == 0:
							path.flags["length"] = 4 + randi() % 6	# 4 - 10
							generate_straight(x, path)
							path.time += 1
						elif path.time == 1 or path.time == 6 + path.flags["length"]:
							generate_straight(x, path)
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 4
							for y in range(bottom_y - 3, bottom_y + 1):
								place_tile(x, y, "wall")
							for y in range(bottom_y - path.width - 7, bottom_y - path.width - 3):
								place_tile(x, y, "wall")
							path.time += 1
						elif path.time <= 3 or path.time == 4 + path.flags["length"] or path.time == 5 + path.flags["length"]:
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 4
							place_tile(x, bottom_y, "wall")
							place_tile(x, bottom_y - path.width - 7, "wall")
							for y in range(bottom_y - path.width - 6, bottom_y):
								place_tile(x, y, "floor")
							path.time += 1
						elif path.time == 4 or path.time == 3 + path.flags["length"]:
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 4
							place_tile(x, bottom_y - path.width - 7, "wall")
							place_tile(x, bottom_y - path.width - 6, "floor")
							place_tile(x, bottom_y - path.width - 5, "floor")
							place_tile(x, bottom_y - path.width - 4, "floor")
							for y in range(bottom_y - path.width - 3, bottom_y - 3):
								place_tile(x, y, "wall")
							place_tile(x, bottom_y - 3, "floor")
							place_tile(x, bottom_y - 2, "floor")
							place_tile(x, bottom_y - 1, "floor")
							place_tile(x, bottom_y, "wall")
							path.time += 1
						elif path.time <= 2 + path.flags["length"]:
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 4
							place_tile(x, bottom_y - path.width - 7, "wall")
							place_tile(x, bottom_y - path.width - 6, "floor")
							place_tile(x, bottom_y - path.width - 5, "floor")
							place_tile(x, bottom_y - path.width - 4, "floor")
							place_tile(x, bottom_y - path.width - 3, "wall")
							place_tile(x, bottom_y - 4, "wall")
							place_tile(x, bottom_y - 3, "floor")
							place_tile(x, bottom_y - 2, "floor")
							place_tile(x, bottom_y - 1, "floor")
							place_tile(x, bottom_y, "wall")
							path.time += 1
						elif path.time == 7 + path.flags["length"]:
							generate_straight(x, path)
							path.finish_structure()
					"pillars":
						if path.time == 0:
							path.flags["columns"] = 2 + randi() % 4	# 2 - 6 columns of pillars
							generate_straight(x, path)
							path.time += 1
						elif path.time == 1 or path.time == 4 + 4 * path.flags["columns"]:
							generate_straight(x, path)
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 5
							for y in range(bottom_y - 4, bottom_y + 1):
								place_tile(x, y, "wall")
							for y in range(bottom_y - path.width - 9, bottom_y - path.width - 4):
								place_tile(x, y, "wall")
							path.time += 1
						elif path.time < 4 + 4 * path.flags["columns"]:
							@warning_ignore("integer_division")
							var bottom_y = path.y + path.width / 2 + 5
							place_tile(x, bottom_y, "wall")
							place_tile(x, bottom_y - path.width - 9, "wall")
							match path.time % 4:
								0, 1:
									place_tile(x, bottom_y - path.width - 8, "floor")
									place_tile(x, bottom_y - path.width - 7, "floor")
									place_tile(x, bottom_y - path.width - 6, "wall")
									place_tile(x, bottom_y - path.width - 5, "wall")
									for y in range(bottom_y - path.width - 4, bottom_y - 4):
										place_tile(x, y, "floor")
									place_tile(x, bottom_y - 4, "wall")
									place_tile(x, bottom_y - 3, "wall")
									place_tile(x, bottom_y - 2, "floor")
									place_tile(x, bottom_y - 1, "floor")
								2, 3:
									for y in range(bottom_y - path.width - 8, bottom_y):
										place_tile(x, y, "floor")
							path.time += 1
						elif path.time == 5 + 4 * path.flags["columns"]:
							generate_straight(x, path)
							path.finish_structure()
					"final":
						if path.flags.has("lock_x"):
							if player.global_position.x / Constants.TILE_SIZE > path.flags["lock_x"]:
								player.target = Vector2(path.flags["lock_x"] + 0.5, path.y + 0.5) * Constants.TILE_SIZE
								ui.block_movement()
						if path.time < 10:
							generate_straight(x, path)
							path.time += 1
						elif path.time == 10:
							var top_y = path.y - 6
							var bottom_y = path.y + 6
							generate_straight(x, path)
							@warning_ignore("integer_division")
							for y in range(top_y, top_y + 6 - ceil(path.width / 2)):
								place_tile(x, y, "wall")
							@warning_ignore("integer_division")
							for y in range(bottom_y - 4 + floor(path.width / 2), bottom_y + 1):
								place_tile(x, y, "wall")
							path.time += 1
						elif path.time <= 27:
							var top_y = path.y - 6
							var bottom_y = path.y + 6
							place_tile(x, top_y, "wall")
							place_tile(x, bottom_y, "wall")
							for y in range(top_y + 1, bottom_y):
								place_tile(x, y, "floor")
							path.time += 1
							if path.time == 15:
								path.flags["lock_x"] = x
						elif path.time == 28:
							var top_y = path.y - 6
							var bottom_y = path.y + 6
							for y in range(top_y, bottom_y + 1):
								place_tile(x, y, "wall")
							enemy_generator.attempt_enemy_spawn("Lich", 1, Vector2i(x - 2, path.y))
							path.time += 1
			x += 1
		highest_generated_x = new_x
	
	draw_to_x_tiles(new_x - 1)

func initialize():
	final_x = 50
	
	max_paths = 3
	structure_weights = {
		"straight": 15,	# No change
		"offset": 10,	# Offset up or down by one
		"width_change": 10,	# Change width
		"turn": 4,	# Go up or down a few tiles
		#"split": 1,	# Diverging paths -> (2x) turn + straight
		"big_empty": 2,	# Big empty room with possible diverging paths
		"double": 2,	# Split corridors by a middle wall
		"pillars": 2,	# Repeating pillars in 2 rows
		"final": 0
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
	
