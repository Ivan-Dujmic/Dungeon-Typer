extends Node2D

@export var radius: float
@export var edge_thickness: float = 1
@export var color: Color = Color.WHITE

func _draw():
	var inner_color = color
	inner_color.a = 0.03
	var edge_color = color
	edge_color.a = 0.07
	draw_circle(Vector2.ZERO, radius, inner_color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, edge_color, edge_thickness)
