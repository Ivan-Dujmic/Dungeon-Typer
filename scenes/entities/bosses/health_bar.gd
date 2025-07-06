extends Node2D

var size = Vector2i(30, 3)
var health_ratio = 1

var empty_color = Color.DIM_GRAY
var health_color = Color.RED

func _ready():
	position = Vector2(-size.x / 2, -30)
	queue_redraw()
	
func _draw():
	var bar_width = size.x * health_ratio
	draw_rect(Rect2(Vector2.ZERO, size), empty_color)
	draw_rect(Rect2(Vector2.ZERO, Vector2(bar_width, size.y)), health_color)
	
func update_health(value: int, max_value: int):
	health_ratio = float(value) / max_value
	queue_redraw()
