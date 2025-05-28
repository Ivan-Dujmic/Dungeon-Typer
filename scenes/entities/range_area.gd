extends Area2D
class_name RangeArea

@onready var collision_circle = $CollisionCircle

func set_range(radius: float):
	collision_circle.shape.radius = radius
	
func _ready():
	return
