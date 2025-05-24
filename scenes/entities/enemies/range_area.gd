extends Area2D

@onready var collision_circle = $CollisionCircle

func set_range(radius: float):
	collision_circle.shape.radius = radius
	
func _ready():
	return
