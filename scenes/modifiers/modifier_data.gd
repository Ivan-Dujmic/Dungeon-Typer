extends Resource
class_name ModifierData

@export var name: String	# Unique identifier
@export var description: String	# For tooltips and such
@export var texture: Texture2D
@export var effect_command: Script
@export var requirements: Script	# Contains func can_roll
