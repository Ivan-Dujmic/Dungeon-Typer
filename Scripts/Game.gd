extends Node2D

@onready var tiles_viewport_container = $TilesViewportContainer
@onready var tiles_viewport = $TilesViewportContainer/TilesViewport

func _ready():
	var viewport = get_viewport_rect()
	var ratio = viewport.size.x / tiles_viewport.size.x
	tiles_viewport_container.scale = Vector2(ratio, ratio)
