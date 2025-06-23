extends Node
class_name DungeonRenderer
# ABSTRACT

var rng = RandomNumberGenerator.new()

func floor() -> Vector2i:
	return Vector2i.ZERO
	
func wall_top() -> Vector2i:
	return Vector2i.ZERO
	
func wall_bottom() -> Vector2i:
	return Vector2i.ZERO
	
func wall_left() -> Vector2i:
	return Vector2i.ZERO
	
func wall_right() -> Vector2i:
	return Vector2i.ZERO
	
func wall_top_left() -> Vector2i:
	return Vector2i.ZERO
	
func wall_top_right() -> Vector2i:
	return Vector2i.ZERO
	
func wall_bottom_left_inner() -> Vector2i:
	return Vector2i.ZERO
	
func wall_bottom_right_inner() -> Vector2i:
	return Vector2i.ZERO
	
func wall_bottom_left_outer() -> Vector2i:
	return Vector2i.ZERO
	
func wall_bottom_right_outer() -> Vector2i:
	return Vector2i.ZERO
