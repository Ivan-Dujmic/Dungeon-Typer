extends Area2D

@onready var collision_circle = $CollisionCircle
@onready var range_indicator = $RangeIndicator

func set_range(radius: float):
	collision_circle.shape.radius = radius
	range_indicator.radius = radius
	
func _ready():
	return
