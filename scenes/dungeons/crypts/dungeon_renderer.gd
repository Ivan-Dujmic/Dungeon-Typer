extends DungeonRenderer

func floor() -> Vector2i:
	return Vector2i(rng.randi_range(6, 9), rng.randi_range(0, 2))
	
func wall_top() -> Vector2i:
	return Vector2i(rng.randi_range(1, 4), 0)
	
func wall_bottom() -> Vector2i:
	return Vector2i(rng.randi_range(1, 4), 4)
	
func wall_left() -> Vector2i:
	return Vector2i(0, rng.randi_range(0, 3))
	
func wall_right() -> Vector2i:
	return Vector2i(5, rng.randi_range(0, 3))
	
func wall_top_left() -> Vector2i:
	return Vector2i(0, rng.randi_range(0, 3))
	
func wall_top_right() -> Vector2i:
	return Vector2i(5, rng.randi_range(0, 3))
	
func wall_bottom_left_inner() -> Vector2i:
	return Vector2i(0, 4)
	
func wall_bottom_right_inner() -> Vector2i:
	return Vector2i(5, 4)

func wall_bottom_left_outer() -> Vector2i:
	return Vector2i(5, 5)
	
func wall_bottom_right_outer() -> Vector2i:
	return Vector2i(4, 5)
