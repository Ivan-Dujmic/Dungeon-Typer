extends CharacterBody2D
class_name Entity

@onready var range_area = $RangeArea
@onready var navigation_agent = $NavigationAgent
@onready var animated_sprite = $AnimatedSprite

# Stats
var max_health: int
var health: int:	# Current health
	set(value):
		health = clamp(value, 0, max_health)
		update_health()
		if health == 0:
			die()
var health_regen: int	# Health regen per second
var attack: int	# Attack power
var action_range: int	# Pixel range in which the player can performs actions
var speed: float	# Movement speed

func update_health():
	return

func take_damage(damage: int):
	health -= damage
	
func heal(healing: int):
	health += healing
	
func die():
	return	

func _on_health_regen_timeout():
	health += health_regen

func _on_range_area_body_entered(_body: Node2D):
	return

func _on_range_area_body_exited(_body: Node2D):
	return
	
func _on_range_area_area_entered(_area: Area2D):
	pass 

func _on_range_area_area_exited(_area: Area2D):
	pass

func _ready():
	return

func _physics_process(_delta):
	return
