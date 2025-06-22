extends Node2D
class_name DungeonBackground

@onready var color_rect = $ColorRect

func _ready():
	z_index = -10
	color_rect.size = get_viewport_rect().size
	position = Vector2(-134, -68)
