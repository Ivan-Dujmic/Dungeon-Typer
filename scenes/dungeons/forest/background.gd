extends Node2D

@onready var color_rect = $ColorRect

func _ready():
	color_rect.size = get_viewport_rect().size
