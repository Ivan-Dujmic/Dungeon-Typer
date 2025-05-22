extends Control

var health_ratio = 1.0

var empty_color = Color.DIM_GRAY
var health_color = Color.GREEN
var border_color = Color.BLACK

func _ready():
	queue_redraw()
	
func _draw():
	var bar_width = size.x * health_ratio
	draw_rect(Rect2(Vector2.ZERO, size), empty_color)
	draw_rect(Rect2(Vector2.ZERO, Vector2(bar_width, size.y)), health_color)
	draw_rect(Rect2(Vector2.ZERO, size), border_color, false, 3.0)
	
func update_health(ratio: float):
	health_ratio = ratio
	queue_redraw()
