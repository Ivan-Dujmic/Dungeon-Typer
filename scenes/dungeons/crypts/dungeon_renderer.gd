extends Node
class_name DungeonRenderer
# ABSTRACT

var rng = RandomNumberGenerator.new()

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
	
func wall_bottom_left() -> Vector2i:
	return Vector2i(0, 4)
	
func wall_bottom_right() -> Vector2i:
	return Vector2i(5, 4)
